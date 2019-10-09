//
//  RecordViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/22.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

protocol RecordViewModelService {
    var habit: HabitModelProtocol { get }
}

extension Models: RecordViewModelService {}

class RecordViewModel {
    public enum MenuItem {
        case detail, edit, cancel
    }

    public struct Inputs {
        public let tapDone: Observable<TimeInterval>
        public let tapOthers: Observable<Void>
    }

    public struct Outputs {
        public let title: Observable<String>
        public let showDetail: Observable<HabitDetailViewModel>
        public let showMenu: Observable<PublishSubject<MenuItem>>
        public let dismiss: Observable<Void>
    }

    private let habitId: HabitID
    private let habitModel: HabitModelProtocol
    private let disposeBag = DisposeBag()

    public init(habitId: HabitID, service: RecordViewModelService = Models.shared) {
        self.habitId = habitId
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let current = currentHabit().share(replay: 1)

        let done = inputs.tapDone.share()

        done.subscribeNext(weak: self, RecordViewModel.addTimeSpent).disposed(by: disposeBag)

        let showDetail = Observable
            .combineLatest(current, inputs.tapOthers)
            .map { habit, _ in
                HabitDetailViewModel(habitId: habit.id)
            }

        let menuItemSelectedSubject = PublishSubject<MenuItem>()

        return Outputs(
            title: current.map { $0.title },
            showDetail: showDetail,
            showMenu: inputs.tapOthers.mapTo(menuItemSelectedSubject),
            dismiss: done.mapTo(())
        )
    }

    private func currentHabit() -> Observable<Habit> {
        let id = habitId
        return habitModel.habits.compactMap { $0.first(where: { $0.habit.id == id }).map { $0.habit } }
    }

    private func addTimeSpent(_ duration: TimeInterval) {
        habitModel.addTimeSpent(duration: duration, to: habitId)
    }
}
