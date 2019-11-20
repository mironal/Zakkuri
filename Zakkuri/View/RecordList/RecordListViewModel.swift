//
//  RecordListViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/05.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxSwiftExt
import SwifterSwift

public protocol RecordListViewModelService {
    var habit: HabitModelProtocol { get }
}

extension Models: RecordListViewModelService {}

public final class RecordListViewModel {
    public struct CellState {
        let title: String?
        let detail: String?
    }

    public struct Inputs {
        let changeCollapse: Observable<Void>
    }

    public struct Outputs {
        let title: Observable<String?>
        let cellStates: Observable<[CellState]>
        let collapse: Observable<Bool>
    }

    private let habitId: HabitID
    private let date: Date
    private let habitModel: HabitModelProtocol

    init(_ habitId: HabitID, date: Date, service: RecordListViewModelService = Models.shared) {
        self.habitId = habitId
        self.date = date
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let date = self.date
        let title = habitModel.habit(by: habitId).map { $0?.title }
        let collapse = inputs.changeCollapse
            .scan(true) { last, _ in !last }
            .startWith(true)
            .share(replay: 1)

        let cellStates: Observable<[CellState]> = .combineLatest(habitModel.habitRecords(by: habitId),
                                                                 collapse) { (records, collapse) -> [RecordListViewModel.CellState] in
            records.filter {
                !collapse || $0.createdAt.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
            }.map {
                let duration = Formatters.spentTime.string(from: $0.duration)
                let createdAt = $0.createdAt.map { Formatters.recordingDate.string(from: $0) }
                return CellState(title: duration, detail: createdAt)
            }
        }

        return .init(
            title: title,
            cellStates: cellStates,
            collapse: collapse
        )
    }
}
