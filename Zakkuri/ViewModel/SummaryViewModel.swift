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
        let showGoalForm: Observable<HabitFormViewModel>
        let habits: Observable<[HabitSummary]>
    }

    private let disposeBag = DisposeBag()
    private let habitModel: HabitModelProtocol

    public init(_ service: SummaryViewModelService = Models.shared) {
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let showGoalForm = inputs.tapAdd.map { HabitFormViewModel() }

        let showRecordView = inputs.selectItem
            .withLatestFrom(habitModel.habits) { (indexPath, habits) -> String in habits[indexPath.row].habit.id }
            // mapと見るとArrayのように、処理した処理後の配列をイメージしてしまうが、Obserberに初期化されたRecordViewModelが詰められたもの？
            // また1行前withLatestFromで最新の一つだけObserberをとってくるだったはず
            .map { RecordViewModel(habitId: $0) }

        inputs.deleteItem
            // おまじない(全然わからん)
            .withLatestFrom(habitModel.habits) { (indexPath, habits) -> String in habits[indexPath.row].habit.id }
            // ビジネスロジックを紐付けている？
            // SummaryViewModel.deleteHabitは引数はないし、スタティックメソッドっぽい書き方で動くの？deleteHabit(habitId: 1)とかじゃないと動かなそうなのに
            .subscribe(weak: self, onNext: SummaryViewModel.deleteHabit).disposed(by: disposeBag)

        return Outputs(
            showRecordView: showRecordView,
            showGoalForm: showGoalForm,
            habits: habitModel.habits
        )
    }

    private func deleteHabit(_ habitId: HabitID) {
        habitModel.delete(habitId)
    }
}
