//
//  Storage.swift
//  laid-back
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
    func restoreHabitRecords() -> Single<[HabitRecord]>

    func add(_ record: HabitRecord) -> Single<Void>
}

public class UserDefaultsStorage: StorageProtocol {
    let defaults: UserDefaults = .standard

    enum Keys: String {
        case habits, habitRecords
    }

    private let disposeBag = DisposeBag()

    private lazy var addHabitSubject: PublishSubject<Habit> = {
        let subject = PublishSubject<Habit>()
        let defaults = self.defaults

        subject
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { habit in
                var habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
                habits.append(habit)
                defaults.set(object: habits, forKey: Keys.habits.rawValue)
                defaults.synchronize()
            })
            .disposed(by: disposeBag)

        return subject
    }()

    public func add(_ habit: Habit) -> Single<Void> {
        addHabitSubject.onNext(habit)
        return .just(())
    }

    public func restoreHabits() -> Single<[Habit]> {
        let habits: [Habit] = defaults.object([Habit].self, with: Keys.habits.rawValue) ?? []
        return .just(habits)
    }

    public func restoreHabitRecords() -> Single<[HabitRecord]> {
        let records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        return .just(records)
    }

    public func add(_ record: HabitRecord) -> Single<Void> {
        var records: [HabitRecord] = defaults.object([HabitRecord].self, with: Keys.habitRecords.rawValue) ?? []
        records.append(record)
        defaults.set(object: records, forKey: Keys.habitRecords.rawValue)
        return .just(())
    }
}
