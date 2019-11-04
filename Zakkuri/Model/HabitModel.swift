//
//  HabitModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxSwiftExt
import SwifterSwift

public protocol HabitModelProtocol {
    typealias HabitRecordMap = [Date: [Habit: [HabitRecord]]]
    var habitRecordMap: Observable<HabitRecordMap> { get }

    /// Behavior
    var habitsSummary: Observable<[HabitSummary]> { get }
    var oldestHabitRecord: Observable<HabitRecord?> { get }

    var allHabitRecords: Observable<[HabitRecord]> { get }
    func habitRecords(by habitId: HabitID) -> Observable<[HabitRecord]>

    func add(_ habit: Habit)
    func delete(_ habitId: HabitID)
    func deleteRecord(_ recordId: String)
    func addTimeSpent(duration: TimeInterval, to habitId: HabitID)
}

public class HabitModel: HabitModelProtocol {
    let queue = DispatchQueue(label: "dev.mironal.HabitModel")
    let storage: StorageProtocol
    init(storage: StorageProtocol) {
        self.storage = storage
    }

    private let disposeBag = DisposeBag()

    private func createHabitSummary(_ habit: Habit) -> Observable<HabitSummary> {
        return Observable.just(())
            .flatMap { self.storage.restoreHabitRecords().map { $0.filter { r in habit.id == r.habitId } } }
            .map {
                guard let endOfToday = Date().end(of: .day) else { fatalError() }
                let from = endOfToday.addingTimeInterval(-habit.goalSpan.duration)
                let spentTimeInDuration = $0.filter {
                    $0.createdAt.isBetween(from, endOfToday)
                }.reduce(0.0) { $0 + $1.duration }
                return HabitSummary(habit: habit,
                                    spentTimeInDuration: spentTimeInDuration)
            }
    }

    private func loadHabitsSummary(_ r: BehaviorRelay<[HabitSummary]>) {
        storage.restoreHabits()
            .asObservable()
            .map { $0.map { self.createHabitSummary($0) } }
            .flatMap { Observable.zip($0) }
            .subscribe(onNext: r.accept).disposed(by: disposeBag)
    }

    public var habitRecordMap: Observable<HabitModelProtocol.HabitRecordMap> {
        return Observable.combineLatest(storage.restoreHabits().asObservable(),
                                        storage.restoreHabitRecords().asObservable())
            .map { (hs: [Habit], hrs: [HabitRecord]) -> HabitRecordMap in
                self.makeHabitMap(hs: hs, records: hrs)
            }
    }

    private func makeHabitMap(hs: [Habit], records: [HabitRecord]) -> HabitRecordMap {
        let dates = records.reduce(into: [Date]()) { result, record in
            guard let rounded = record.createdAt.beginning(of: .day) else { return }
            if !result.contains(rounded) {
                result.append(rounded)
            }
        }

        let habitMap = dates.reduce(into: HabitRecordMap()) { result, date in

            let habitRecords: [Habit: [HabitRecord]] = records.filter { $0.createdAt.beginning(of: .day) == date }
                .reduce(into: [HabitID: [HabitRecord]]()) { result, r in
                    var records = result[r.habitId] ?? []
                    records.append(r)
                    result[r.habitId] = records
                }.compactMapKeysAndValues { (arg) -> (Habit, [HabitRecord])? in
                    let (key, value) = arg
                    guard let habit = hs.first(where: { $0.id == key }) else { return nil }
                    return (habit, value)
                }

            result[date] = habitRecords
        }

        return habitMap
    }

    private lazy var habitsSummaryRelay: BehaviorRelay<[HabitSummary]> = {
        let r = BehaviorRelay<[HabitSummary]>(value: [])
        loadHabitsSummary(r)
        return r
    }()

    public var habitsSummary: Observable<[HabitSummary]> {
        return habitsSummaryRelay.asObservable()
    }

    public var oldestHabitRecord: Observable<HabitRecord?> {
        return storage.restoreHabitRecords()
            .asObservable()
            .map { records -> HabitRecord? in

                guard let first = records.first else { return nil }
                let record: HabitRecord? = records.reduce(into: first) { result, record in
                    if result.createdAt > record.createdAt {
                        result = record
                    }
                }
                return record
            }
    }

    public func habitRecords(by habitId: HabitID) -> Observable<[HabitRecord]> {
        return storage.restoreHabitRecords().map {
            $0.filter { $0.habitId == habitId }
        }.asObservable()
    }

    public var allHabitRecords: Observable<[HabitRecord]> {
        return storage.restoreHabitRecords().asObservable()
    }

    public func add(_ habit: Habit) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var value = self.habitsSummaryRelay.value

            let summary = HabitSummary(habit: habit, spentTimeInDuration: 0)
            value.append(summary)
            self.habitsSummaryRelay.accept(value)

            _ = self.storage.add(habit)
        }
    }

    public func delete(_ habitId: HabitID) {
        queue.async { [weak self] in
            guard let self = self else { return }
            _ = self.storage.deleteHabitAndRecords(habitId)
            self.loadHabitsSummary(self.habitsSummaryRelay)
        }
    }

    public func deleteRecord(_ recordId: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            _ = self.storage.deleteRecord(recordId)
            self.loadHabitsSummary(self.habitsSummaryRelay)
        }
    }

    public func addTimeSpent(duration: TimeInterval, to habitId: HabitID) {
        let record = HabitRecord(habitId: habitId, duration: duration, createdAt: Date())
        add(record)
    }

    public func add(_ record: HabitRecord) {
        queue.async { [weak self] in
            guard let self = self else { return }
            _ = self.storage.add(record)
            self.loadHabitsSummary(self.habitsSummaryRelay)
        }
    }
}
