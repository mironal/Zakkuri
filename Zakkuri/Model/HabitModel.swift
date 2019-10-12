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
    /// Behavior
    var habits: Observable<[HabitSummary]> { get }

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
        return Observable.just(habit)
            .flatMap { self.storage.restoreHabitRecords(by: $0.id) }
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

    private lazy var habitsRelay: BehaviorRelay<[HabitSummary]> = {
        let r = BehaviorRelay<[HabitSummary]>(value: [])
        loadHabitsSummary(r)
        return r
    }()

    public var habits: Observable<[HabitSummary]> {
        return habitsRelay.asObservable()
    }

    public func habitRecords(by habitId: HabitID) -> Observable<[HabitRecord]> {
        return storage.restoreHabitRecords(by: habitId).asObservable()
    }

    public func add(_ habit: Habit) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var value = self.habitsRelay.value

            let summary = HabitSummary(habit: habit, spentTimeInDuration: 0)
            value.append(summary)
            self.habitsRelay.accept(value)

            _ = self.storage.add(habit)
        }
    }

    public func delete(_ habitId: HabitID) {
        queue.async { [weak self] in
            guard let self = self else { return }
            _ = self.storage.deleteHabitAndRecords(habitId)
            self.loadHabitsSummary(self.habitsRelay)
        }
    }

    public func deleteRecord(_ recordId: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            _ = self.storage.deleteRecord(recordId)
            self.loadHabitsSummary(self.habitsRelay)
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
            self.loadHabitsSummary(self.habitsRelay)
        }
    }
}
