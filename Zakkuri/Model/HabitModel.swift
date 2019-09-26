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

public enum GoalSpan: Int, CaseIterable, Codable {
    case aDay, aWeek, aMonth
    var localizedString: String {
        switch self {
        case .aDay: return "24 hours"
        case .aWeek: return "7 days"
        case .aMonth: return "30 days"
        }
    }
}

public typealias HabitID = String

public struct Habit: Codable {
    let id: HabitID
    let title: String
    let goalSpan: GoalSpan
    let targetTime: TimeInterval

    init(createNewHabitWithTitle title: String, goalSpan: GoalSpan, targetTime: TimeInterval) {
        id = UUID().uuidString
        self.title = title
        self.goalSpan = goalSpan
        self.targetTime = targetTime
    }

    var readableString: String {
        let time = Habit.timeFormatter.string(from: targetTime) ?? ""
        return "\(goalSpan.localizedString)に\(time)時間 \"\(title)\" をする"
    }

    static let timeFormatter: DateComponentsFormatter = {
        let fmt = DateComponentsFormatter()
        fmt.allowedUnits = [.hour]
        return fmt
    }()
}

public struct HabitRecord: Codable {
    let habitId: HabitID
    let duration: TimeInterval
    let createdAt: Date

    var recordId: String {
        return "\(habitId)_\(createdAt.unixTimestamp)"
    }
}

public struct HabitSummary {
    let habit: Habit
    let spentTimeInDuration: TimeInterval

    var summary: String {
        let fmt = DateComponentsFormatter()
        fmt.allowedUnits = [.hour, .minute]
        fmt.unitsStyle = .short

        return "You spent \(fmt.string(from: spentTimeInDuration) ?? "0") in the last \(habit.goalSpan.localizedString)"
    }
}

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
                let spentTimeInDuration = $0.reduce(0.0) { $0 + $1.duration }
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
