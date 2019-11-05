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

    public struct Inputs {}
    public struct Outputs {
        let title: Observable<String?>
        let cellStates: Observable<[CellState]>
    }

    private let habitId: HabitID
    private let habitModel: HabitModelProtocol

    init(_ habitId: HabitID, service: RecordListViewModelService = Models.shared) {
        self.habitId = habitId
        habitModel = service.habit
    }

    public func bind(_: Inputs) -> Outputs {
        let title = habitModel.habit(by: habitId).map { $0?.title }

        let cellStates: Observable<[CellState]> = habitModel.habitRecords(by: habitId)
            .map {
                $0.map {
                    let duration = Formatters.spentTime.string(from: $0.duration)
                    let createdAt = Formatters.recordingDate.string(from: $0.createdAt)
                    return CellState(title: duration, detail: createdAt)
                }
            }

        return .init(
            title: title,
            cellStates: cellStates
        )
    }
}
