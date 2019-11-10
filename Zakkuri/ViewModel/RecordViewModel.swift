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
        public let createdAt: Observable<Date?>
    }

    public struct Outputs {
        public let title: Observable<String>
        public let showDetail: Observable<HabitDetailViewModel>
        public let showEdit: Observable<HabitFormViewModel>
        public let showMenu: Observable<PublishSubject<MenuItem>>
        public let dismiss: Observable<Void>
    }

    private let habitId: HabitID
    private let createdAt: Date?
    private let habitModel: HabitModelProtocol
    private let disposeBag = DisposeBag()

    public init(habitId: HabitID, createdAt: Date? = nil, service: RecordViewModelService = Models.shared) {
        self.habitId = habitId
        self.createdAt = createdAt
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let current = currentHabit().share(replay: 1)

        let done = inputs.tapDone.share()

        done.withLatestFrom(inputs.createdAt.startWith(createdAt)) { duration, createdAt in
            (duration: duration, createdAt: createdAt)
        }.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.addTimeSpent($0.duration, createdAt: $0.createdAt)
        }).disposed(by: disposeBag)

        let menuItemSelectedSubject = PublishSubject<MenuItem>()

        let showDetail = menuItemSelectedSubject
            .filter { $0 == .detail }
            .withLatestFrom(current)
            .compactMap { $0.id.map { HabitDetailViewModel(habitId: $0) } }

        let showEdit = menuItemSelectedSubject
            .filter { $0 == .edit }
            .withLatestFrom(current)
            .map { HabitFormViewModel(habit: $0) }

        return Outputs(
            title: current.map { $0.title },
            showDetail: showDetail,
            showEdit: showEdit,
            showMenu: inputs.tapOthers.mapTo(menuItemSelectedSubject),
            dismiss: done.mapTo(())
        )
    }

    private func currentHabit() -> Observable<Habit> {
        let id = habitId
        return habitModel.habitsSummary.compactMap { $0.first(where: { $0.habit.id == id }).map { $0.habit } }
    }

    private func addTimeSpent(_ duration: TimeInterval, createdAt date: Date?) {
        habitModel.addTimeSpent(duration: duration, to: habitId, createdAt: date)
    }
}
