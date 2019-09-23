//
//  Storage.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxSwift
import SwifterSwift

public protocol StorageProtocol {
    func add(_ habit: Habit) -> Single<Void>
    func restoreHabits() -> Single<[Habit]>
    func restoreHabitRecords(by id: HabitID) -> Single<[HabitRecord]>

    func add(_ record: HabitRecord) -> Single<Void>

    func deleteHabitAndRecords(_ habitId: HabitID) -> Single<HabitID>
}

public class UserDefaultsStorage: StorageProtocol {
    let defaults: UserDefaults = .standard

    enum Keys: String {
        case habits, habitRecords
    }

    private let disposeBag = DisposeBag()

    public func restoreHabits() -> Single<[Habit]> {
        let habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        return .just(habits)
    }

    public func restoreHabitRecords(by id: HabitID) -> Single<[HabitRecord]> {
        let records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        let filterd = records.filter { $0.habitId == id }

        return .just(filterd)
    }

    public func add(_ habit: Habit) -> Single<Void> {
        var habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        habits.append(habit)
        defaults.set(habits, forKey: Keys.habits.rawValue)

        return .just(())
    }

    public func add(_ record: HabitRecord) -> Single<Void> {
        var records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        records.append(record)
        defaults.set(object: records, forKey: Keys.habitRecords.rawValue)
        return .just(())
    }

    public func deleteHabitAndRecords(_ habitId: HabitID) -> Single<HabitID> {
        let habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        let filteredHabits = habits.reject(where: { $0.id == habitId })
        defaults.set(object: filteredHabits, forKey: Keys.habits.rawValue)

        let records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        let filteredRecords = records.reject(where: { $0.habitId == habitId })
        defaults.set(object: filteredRecords, forKey: Keys.habitRecords.rawValue)

        return .just(habitId)
    }
}
