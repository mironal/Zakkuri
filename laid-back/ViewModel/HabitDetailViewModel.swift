//
//  HabitDetailViewModel.swift
//  laid-back
//
//  Created by mironal on 2019/09/22.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxSwift

public protocol HabitDetailViewModelService {
    var habit: HabitModelProtocol { get }
}

extension Models: HabitDetailViewModelService {}

public class HabitDetailViewModel {
    public struct Inputs {
        public let tapClose: Observable<Void>
    }

    public struct Outputs {
        public let habitRecords: Observable<[HabitRecord]>
        public let dismiss: Observable<Void>
    }

    private let habitId: HabitID
    private let habitModel: HabitModelProtocol
    private let disposeBag = DisposeBag()

    public init(habitId: HabitID, service: HabitDetailViewModelService = Models.shared) {
        self.habitId = habitId
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        return Outputs(
            habitRecords: habitModel.habitRecords(by: habitId).share(replay: 1),
            dismiss: inputs.tapClose
        )
    }
}
