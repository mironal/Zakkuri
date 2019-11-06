//
//  Storage.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import SwifterSwift

public protocol StorageProtocol {
    var habits: Observable<[Habit]> { get }
    var habitRecords: Observable<[HabitRecord]> { get }

    func add(_ habit: Habit)
    func add(_ record: HabitRecord)

    func deleteHabitAndRecords(_ habitId: HabitID)
    func deleteRecord(_ recordId: String)
}

public class UserDefaultsStorage: StorageProtocol {
    let defaults: UserDefaults = .standard

    enum Keys: String {
        case habits, habitRecords
    }

    private let disposeBag = DisposeBag()

    public var __habits: [Habit] {
        let habits = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        print("habits", habits)
        return habits
    }

    public func deleteAllHabits() {
        return defaults.removeObject(forKey: Keys.habits.rawValue)
    }

    public var __record: [HabitRecord] {
        return defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
    }

    public func deleteAllRecords() {
        defaults.removeObject(forKey: Keys.habitRecords.rawValue)
    }

    private lazy var habitsSubject: BehaviorRelay<[Habit]> = {
        let habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        let subject = BehaviorRelay<[Habit]>(value: habits)
        return subject

    }()

    public var habits: Observable<[Habit]> {
        return habitsSubject.asObservable()
    }

    private lazy var habitRecordsSubject: BehaviorRelay<[HabitRecord]> = {
        let records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        let subject = BehaviorRelay<[HabitRecord]>(value: records)
        return subject
    }()

    public var habitRecords: Observable<[HabitRecord]> {
        return habitRecordsSubject.asObservable()
    }

    public func add(_ habit: Habit) {
        var habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        habits.append(habit)
        defaults.set(object: habits, forKey: Keys.habits.rawValue)

        habitsSubject.accept(habitsSubject.value + [habit])
    }

    public func add(_ record: HabitRecord) {
        var records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        records.append(record)
        defaults.set(object: records, forKey: Keys.habitRecords.rawValue)

        habitRecordsSubject.accept(habitRecordsSubject.value + [record])
    }

    public func deleteHabitAndRecords(_ habitId: HabitID) {
        let habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        let filteredHabits = habits.reject(where: { $0.id == habitId })
        defaults.set(object: filteredHabits, forKey: Keys.habits.rawValue)

        habitsSubject.accept(filteredHabits)

        let records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        let filteredRecords = records.reject(where: { $0.habitId == habitId })
        defaults.set(object: filteredRecords, forKey: Keys.habitRecords.rawValue)

        habitRecordsSubject.accept(filteredRecords)
    }

    public func deleteRecord(_ recordId: String) {
        let records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        let filteredRecords = records.reject(where: { $0.id == recordId })
        defaults.set(object: filteredRecords, forKey: Keys.habitRecords.rawValue)

        habitRecordsSubject.accept(filteredRecords)
    }
}
