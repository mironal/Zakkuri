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
    }

    public struct Outputs {
        let startTitleEditing: Observable<Void>
        let span: Observable<GoalSpan>
        let goalTime: Observable<TimeInterval>
        let readableString: Observable<String>
        let showSelectSpan: Observable<Void>
        let showTimePicker: Observable<Void>
        let canSave: Observable<Bool>
        let dismiss: Observable<Void>
    }

    private let disposeBag = DisposeBag()

    let habitModel: HabitModelProtocol
    init(_ service: HabitFormViewModelService = Models.shared) {
        habitModel = service.habit
    }

    func bind(_ inputs: Inputs) -> Outputs {
        let habit = createHabit(inputs)
            .share(replay: 1)

        let canSave = habit
            .map { $0.targetTime > 0 && !$0.title.isEmpty }
            .startWith(false)

        let saved = inputs.tapSave.withLatestFrom(habit)
            .flatMap(addHabit)
            .share()

        return Outputs(
            startTitleEditing: inputs.tapItem.filterMap { $0 == .title ? .map(()) : .ignore },
            span: inputs.selectSpan,
            goalTime: inputs.selectGoalTime,
            readableString: habit.map { $0.readableString }.distinctUntilChanged(),
            showSelectSpan: inputs.tapItem.filterMap { $0 == .span ? .map(()) : .ignore },
            showTimePicker: inputs.tapItem.filterMap { $0 == .goalTime ? .map(()) : .ignore },
            canSave: canSave,
            dismiss: .merge(inputs.tapCancel, saved)
        )
    }

    private func createHabit(_ inputs: Inputs) -> Observable<Habit> {
        let habit: Observable<Habit> = Observable.combineLatest(
            inputs.changeTitle,
            inputs.selectSpan,
            inputs.selectGoalTime
        ) { Habit(createNewHabitWithTitle: $0, goalSpan: $1, targetTime: $2) }
        return habit
    }

    private func addHabit(_ habit: Habit) -> Observable<Void> {
        habitModel.add(habit)

        return .just(())
    }
}
