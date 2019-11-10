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
    var visibleCalendarRange: Observable<(start: Date, end: Date)> { get }

    func habit(by habitId: HabitID) -> Observable<Habit?>
    func habitRecords(by habitId: HabitID) -> Observable<[HabitRecord]>

    func add(_ habit: Habit)
    func delete(_ habitId: HabitID)
    func deleteRecord(_ recordId: String)
    func addTimeSpent(duration: TimeInterval, to habitId: HabitID)
    func addTimeSpent(duration: TimeInterval, to habitId: HabitID, createdAt date: Date?)
}

public class HabitModel: HabitModelProtocol {
    let queue = DispatchQueue(label: "dev.mironal.HabitModel")
    let storage: StorageProtocol
    init(storage: StorageProtocol) {
        self.storage = storage
    }

    private let disposeBag = DisposeBag()

    private func createHabitSummary(_ habit: Habit) -> Observable<HabitSummary> {
        return storage.habitRecords
            .map { $0.filter { $0.habitId == habit.id } }
            .map {
                guard let endOfToday = Date().end(of: .day) else { fatalError() }
                let from = endOfToday.addingTimeInterval(-habit.goalSpan.duration)
                let spentTimeInDuration = $0.filter { $0.createdAt?.isBetween(from, endOfToday) ?? false }
                    .reduce(0.0) { $0 + $1.duration }
                return HabitSummary(habit: habit,
                                    spentTimeInDuration: spentTimeInDuration)
            }
    }

    public var habitRecordMap: Observable<HabitModelProtocol.HabitRecordMap> {
        return Observable.combineLatest(storage.habits,
                                        storage.habitRecords)
            .map { (hs: [Habit], hrs: [HabitRecord]) -> HabitRecordMap in
                self.makeHabitMap(hs: hs, records: hrs)
            }
    }

    private func makeHabitMap(hs: [Habit], records: [HabitRecord]) -> HabitRecordMap {
        let dates = records.reduce(into: [Date]()) { result, record in
            guard let rounded = record.createdAt?.beginning(of: .day) else { return }
            if !result.contains(rounded) {
                result.append(rounded)
            }
        }

        let habitMap = dates.reduce(into: HabitRecordMap()) { result, date in

            let habitRecords: [Habit: [HabitRecord]] = records.filter { $0.createdAt?.beginning(of: .day) == date }
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

    public private(set) lazy var habitsSummary: Observable<[HabitSummary]> = {
        storage.habits
            .map { $0.map { self.createHabitSummary($0) } }
            .flatMapLatest { $0.isEmpty ? .just([]) : Observable.zip($0) }
            .share()
    }()

    public var visibleCalendarRange: Observable<(start: Date, end: Date)> {
        return storage.habitRecords
            .map { records -> HabitRecord? in
                guard let first = records.first else { return nil }
                let record: HabitRecord? = records.reduce(into: first) { result, record in
                    guard let a = result.createdAt, let b = record.createdAt else { return }

                    if a > b {
                        result = record
                    }
                }
                return record
            }
            .map { record in

                func makeRange(_ d: Date) -> (start: Date, end: Date) {
                    if let start = d.beginning(of: .month)?.adding(.month, value: -1),
                        let end = d.end(of: .month) {
                        return (start: start, end: end)
                    }

                    // fallback
                    return (start: Date(), end: Date())
                }

                if let date = record?.createdAt {
                    return makeRange(date)
                }

                // record ゼロ件のときはげ今日を起点にする
                return makeRange(Date())
            }
            .share(replay: 1)
    }

    public func habit(by habitId: HabitID) -> Observable<Habit?> {
        return storage.habits.map { $0.first(where: { $0.id == habitId }) }
    }

    public func habitRecords(by habitId: HabitID) -> Observable<[HabitRecord]> {
        return storage.habitRecords.map {
            // TODO: sort は storage 側の query で行う
            $0.filter { $0.habitId == habitId } // .sorted(by: \.createdAt).reversed()
        }
    }

    public func add(_ habit: Habit) {
        queue.async { [weak self] in
            guard let self = self else { return }

            self.storage.add(habit)
        }
    }

    public func delete(_ habitId: HabitID) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.storage.deleteHabitAndRecords(habitId)
        }
    }

    public func deleteRecord(_ recordId: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.storage.deleteRecord(recordId)
        }
    }

    public func addTimeSpent(duration: TimeInterval, to habitId: HabitID) {
        addTimeSpent(duration: duration, to: habitId, createdAt: nil)
    }

    public func addTimeSpent(duration: TimeInterval, to habitId: HabitID, createdAt date: Date? = nil) {
        let record = HabitRecord(habitId: habitId, duration: duration, createdAt: date)
        add(record)
    }

    public func add(_ record: HabitRecord) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.storage.add(record)
        }
    }
}
