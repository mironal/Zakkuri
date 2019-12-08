//
//  SummaryViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/13.
//  Copyright © 2019 mironal. All rights reserved.
//

import FirebaseAnalytics
import Foundation
import RxRelay
import RxSwift
import RxSwiftExt

public protocol SummaryViewModelService {
    var habit: HabitModelProtocol { get }
}

extension Models: SummaryViewModelService {}

public class SummaryViewModel {
    public typealias ReorderDescription = (srcRow: Int, destRow: Int)
    public struct Inputs {
        public let tapAdd: Observable<Void>
        public let tapSetting: Observable<Void>

        // tableview
        public let selectItem: Observable<IndexPath>
        public let deleteItem: Observable<IndexPath>
        public let reorder: Observable<ReorderDescription>
    }

    public struct Outputs {
        let loading: Observable<Bool>
        let showRecordView: Observable<RecordViewModel>
        let showHabitForm: Observable<HabitFormViewModel>
        let showSetting: Observable<SettingViewModel>
        let habitCells: Observable<[SectionOfSummaryCellState]>
    }

    private let disposeBag = DisposeBag()
    private let habitModel: HabitModelProtocol

    public init(_ service: SummaryViewModelService = Models.shared) {
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let showGoalForm = inputs.tapAdd.map { HabitFormViewModel() }

        let loadingSummary = habitModel.habitsSummary.loadingContent()

        let showRecordView = inputs.selectItem
            .withLatestFrom(loadingSummary.content) { (indexPath, habits) -> HabitID? in habits[indexPath.row].habit.id }
            .compactMap { $0.map { RecordViewModel(habitId: $0, analytics: "summary") } }

        inputs.deleteItem
            .withLatestFrom(habitModel.habitsSummary) { (indexPath, habits) -> HabitID? in habits[indexPath.row].habit.id }
            .subscribe(weak: self, onNext: SummaryViewModel.deleteHabit).disposed(by: disposeBag)

        let habitCells: Observable<[SummaryCellState]> = habitModel.habitsSummary
            .map { $0.map { $0 as SummaryCellState } }

        inputs.reorder.subscribe(onNext: { [weak self] in
            self?.habitModel.reorderHabit(srcIndex: $0.srcRow, destIndex: $0.destRow)
        }).disposed(by: disposeBag)

        return Outputs(
            loading: loadingSummary.loading,
            showRecordView: showRecordView,
            showHabitForm: showGoalForm,
            showSetting: inputs.tapSetting.map { SettingViewModel() },
            habitCells: habitCells.map { [SectionOfSummaryCellState(items: $0)] }
        )
    }

    private func deleteHabit(_ habitId: HabitID?) {
        habitId.map { habitModel.delete($0) }
        Analytics.logEvent(AnalyticsEventSelectContent,
                           value: SelectContentEventValue.deletedHabit)
    }
}
