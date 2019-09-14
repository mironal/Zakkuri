//
//  SummaryViewModel.swift
//  laid-back
//
//  Created by mironal on 2019/09/13.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxSwiftExt

public protocol SummaryViewModelService {
    var habit: HabitModelProtocol { get }
}

extension Models: SummaryViewModelService {}

public class SummaryViewModel {
    public struct Inputs {
        public let tapAdd: Observable<Void>
    }

    public struct Outputs {
        let showGoalForm: Observable<HabitFormViewModel>
        let habits: Observable<[Habit]>
    }

    private let habitModel: HabitModelProtocol

    public init(_ service: SummaryViewModelService = Models.shared) {
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let showGoalForm = inputs.tapAdd.map { HabitFormViewModel() }

        return Outputs(
            showGoalForm: showGoalForm,
            habits: habitModel.habits
        )
    }
}
