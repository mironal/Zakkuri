//
//  SummaryViewModel.swift
//  Zakkuri
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

        // tableview
        public let selectItem: Observable<IndexPath>
        public let deleteItem: Observable<IndexPath>
    }

    public struct Outputs {
        let showRecordView: Observable<RecordViewModel>
        let showHabitForm: Observable<HabitFormViewModel>
        let habitCells: Observable<[SummaryCellState]>
    }

    private let disposeBag = DisposeBag()
    private let habitModel: HabitModelProtocol

    public init(_ service: SummaryViewModelService = Models.shared) {
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let showGoalForm = inputs.tapAdd.map { HabitFormViewModel() }

        let showRecordView = inputs.selectItem
            .withLatestFrom(habitModel.habitsSummary) { (indexPath, habits) -> HabitID? in habits[indexPath.row].habit.id }
            .compactMap { $0.map { RecordViewModel(habitId: $0) } }

        inputs.deleteItem
            .withLatestFrom(habitModel.habitsSummary) { (indexPath, habits) -> HabitID? in habits[indexPath.row].habit.id }
            .subscribe(weak: self, onNext: SummaryViewModel.deleteHabit).disposed(by: disposeBag)

        let habitCells: Observable<[SummaryCellState]> = habitModel.habitsSummary.map { $0.map { $0 as SummaryCellState } }.debug("habitsSummary cells")

        return Outputs(
            showRecordView: showRecordView,
            showHabitForm: showGoalForm,
            habitCells: habitCells
        )
    }

    private func deleteHabit(_ habitId: HabitID?) {
        habitId.map { habitModel.delete($0) }
    }
}
