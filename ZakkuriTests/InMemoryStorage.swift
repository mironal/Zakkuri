//
//  InMemoryStorage.swift
//  ZakkuriTests
//
//  Created by mironal on 2019/09/26.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxSwift
import Zakkuri

public class InMemoryStorage: StorageProtocol {
    public var habits: [Habit] = []
    public var habitRecords: [HabitRecord] = []

    public func add(_ habit: Habit) -> Single<Void> {
        habits.append(habit)
        return .just(())
    }

    public func restoreHabits() -> Single<[Habit]> {
        return .just(habits)
    }

    public func restoreHabitRecords(by id: HabitID) -> Single<[HabitRecord]> {
        return .just(habitRecords.filter { $0.habitId == id })
    }

    public func add(_ record: HabitRecord) -> Single<Void> {
        habitRecords.append(record)
        return .just(())
    }

    public func deleteHabitAndRecords(_ habitId: HabitID) -> Single<HabitID> {
        habits.removeAll { $0.id == habitId }
        habitRecords.removeAll { $0.habitId == habitId }

        return .just(habitId)
    }

    public func deleteRecord(_ recordId: String) -> Single<String> {
        habitRecords.removeAll { $0.recordId == recordId }
        return .just(recordId)
    }
}
