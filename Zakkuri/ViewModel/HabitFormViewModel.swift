//
//  HabitFormViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxSwiftExt

public protocol HabitFormViewModelService {
    var habit: HabitModelProtocol { get }
    var notify: NotifyModelProtocol { get }
}

extension Models: HabitFormViewModelService {}

public class HabitFormViewModel {
    public enum TappedItem {
        case title, span, goalTime
    }

    public struct Inputs {
        let changeTitle: Observable<String>
        let tapCancel: Observable<Void>
        let tapSave: Observable<Void>
        let tapItem: Observable<TappedItem>
        let selectSpan: Observable<GoalSpan>
        let selectGoalTime: Observable<TimeInterval>
        let toggleNotify: Observable<Bool>
    }

    public struct Outputs {
        let startTitleEditing: Observable<Void>
        let span: Observable<GoalSpan>
        let goalTime: Observable<TimeInterval>
        let notify: Observable<Bool>
        let readableString: Observable<String>
        let showSelectSpan: Observable<Void>
        let showTimePicker: Observable<Void>
        let canNotify: Observable<Bool>
        let canSave: Observable<Bool>
        let dismiss: Observable<Void>
    }

    private let disposeBag = DisposeBag()

    private let habitModel: HabitModelProtocol
    private let notifyModel: NotifyModelProtocol
    private let initialHabit: Habit?
    init(habit: Habit? = nil, _ service: HabitFormViewModelService = Models.shared) {
        initialHabit = habit
        habitModel = service.habit
        notifyModel = service.notify
    }

    func bind(_ inputs: Inputs) -> Outputs {
        let toggleNotify = inputs.toggleNotify
            .flatMapLatest { [weak self] isOn -> Single<Bool> in
                guard let self = self else { return .just(false) }
                // On になったら requestAuthorization の結果を使う
                // それ以外は false
                return isOn ? self.notifyModel.requestAuthorization() : .just(false)
            }.catchErrorJustReturn(false)

        let habit = createHabit(inputs, notificationGranted: toggleNotify)
            .share(replay: 1)

        let canSave = habit
            .map { $0.targetTime > 0 && !$0.title.isEmpty }
            .startWith(false)

        let saved = inputs.tapSave.withLatestFrom(habit)
            .flatMap(addHabit)
            .share()

        return Outputs(
            startTitleEditing: inputs.tapItem.filterMap { $0 == .title ? .map(()) : .ignore },
            span: habit.map { $0.goalSpan }.distinctUntilChanged(),
            goalTime: habit.map { $0.targetTime }.distinctUntilChanged(),
            notify: habit.map { $0.notify }.distinctUntilChanged(),
            readableString: habit.map { $0.readableString }.distinctUntilChanged(),
            showSelectSpan: inputs.tapItem.filterMap { $0 == .span ? .map(()) : .ignore },
            showTimePicker: inputs.tapItem.filterMap { $0 == .goalTime ? .map(()) : .ignore },
            canNotify: notifyModel.deniedNotification.not(),
            canSave: canSave,
            dismiss: .merge(inputs.tapCancel, saved)
        )
    }

    private func createHabit(_ inputs: Inputs, notificationGranted: Observable<Bool>) -> Observable<Habit> {
        let initialHabit = self.initialHabit ??
            Habit(createNewHabitWithTitle: "", goalSpan: .aWeek, targetTime: 25200, notify: false)

        let habit: Observable<Habit> = Observable.combineLatest(
            Observable<HabitID>.just(initialHabit.id),
            inputs.changeTitle.startWith(initialHabit.title),
            inputs.selectSpan.startWith(initialHabit.goalSpan),
            inputs.selectGoalTime.startWith(initialHabit.targetTime),
            notificationGranted.startWith(initialHabit.notify)
        ) { Habit(id: $0, title: $1, goalSpan: $2, targetTime: $3, notify: $4) }
            .debug("changeTitle:createHabit")
        return habit
    }

    private func addHabit(_ habit: Habit) -> Observable<Void> {
        habitModel.add(habit)

        return .just(())
    }
}
