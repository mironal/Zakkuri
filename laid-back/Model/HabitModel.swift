//
//  HabitModel.swift
//  laid-back
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
        case .aDay: return "1日"
        case .aWeek: return "1週間"
        case .aMonth: return "1ヶ月"
        }
    }
}

public typealias HabitID = String

public struct Habit: Codable {
    let id: HabitID = UUID().uuidString
    let title: String
    let goalSpan: GoalSpan
    let targetTime: TimeInterval

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
}

public protocol HabitModelProtocol {
    /// Behavior
    var habits: Observable<[Habit]> { get }

    func recordByHabitId(_ id: HabitID) -> Observable<[HabitRecord]>

    func add(_ habit: Habit)

    func addTimeSpent(duration: TimeInterval, to habitId: HabitID)
}

public class HabitModel: HabitModelProtocol {
    let storage: StorageProtocol
    init(storage: StorageProtocol) {
        self.storage = storage
    }

    private let disposeBag = DisposeBag()
    private let recordRelay = BehaviorRelay<[HabitRecord]>(value: [])

    private lazy var habitsRelay: BehaviorRelay<[Habit]> = {
        let r = BehaviorRelay<[Habit]>(value: [])

        storage.restoreHabits().subscribe(onSuccess: r.accept).disposed(by: disposeBag)

        return r
    }()

    public var habits: Observable<[Habit]> {
        return habitsRelay.asObservable()
    }

    public func recordByHabitId(_ id: HabitID) -> Observable<[HabitRecord]> {
        return recordRelay.map { $0.filter { $0.habitId == id } }
    }

    public func add(_ habit: Habit) {
        var value = habitsRelay.value
        value.append(habit)
        habitsRelay.accept(value)

        _ = storage.add(habit)
    }

    public func addTimeSpent(duration: TimeInterval, to habitId: HabitID) {
        let record = HabitRecord(habitId: habitId, duration: duration, createdAt: Date())
        add(record)
    }

    public func add(_ record: HabitRecord) {
        var value = recordRelay.value
        value.append(record)
        recordRelay.accept(value)

        _ = storage.add(record)
    }
}
