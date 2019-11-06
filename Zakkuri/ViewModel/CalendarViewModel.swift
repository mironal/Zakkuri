//
//  CalendarViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxSwiftExt
import SwifterSwift

public protocol CalendarViewModelService {
    var habit: HabitModelProtocol { get }
}

extension Models: CalendarViewModelService {}

public final class CalendarViewModel {
    public struct CellState {
        let habitId: HabitID
        let title: String
        let duration: String
    }

    public typealias DateRange = (start: Date, end: Date)
    public typealias RecordsMap = [Date: [(habit: Habit, duration: TimeInterval)]]

    public struct Inputs {
        let selectDate: Observable<Date>
        let selectHabit: Observable<IndexPath>
    }

    public struct Outputs {
        let calendarRange: Observable<DateRange>
        let didChangeRecords: Observable<Void>
        let cellState: Observable<[CellState]>
        let deselectTableViewCell: Observable<IndexPath>
        let pushRecordList: Observable<RecordListViewModel>
    }

    private let disposeBag = DisposeBag()
    private let habitModel: HabitModelProtocol

    public private(set) var recordsMap: RecordsMap = [:]

    public init(_ service: CalendarViewModelService = Models.shared) {
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let calendarRange: Observable<DateRange> = habitModel.oldestHabitRecord
            .compactMap {
                guard let oldest = $0?.createdAt else { return nil }
                guard let start = oldest.beginning(of: .month)?.adding(.month, value: -1),
                    let end = Date().end(of: .month) else { return nil }
                return (start: start, end: end)
            }

        let habitRecords = habitModel.habitRecordMap

        let recordsMap = habitRecords.map {
            $0.mapKeysAndValues { arg -> (Date, [(habit: Habit, duration: TimeInterval)]) in

                let (key, value) = arg

                let habits: [Habit] = value.keys.map { $0 }
                let habitDurations = habits.map { habit -> (habit: Habit, duration: TimeInterval) in
                    let duration = (value[habit] ?? []).reduce(into: 0) { sum, r in
                        sum += r.duration
                    }
                    return (habit: habit, duration: duration)
                }

                return (key, habitDurations)
            }
        }
        .do(onNext: { self.recordsMap = $0 })
        .share()

        let cellState = Observable.combineLatest(recordsMap, inputs.selectDate) { (records, date) -> [CellState] in
            let habits = records[date] ?? []
            return habits.map {
                CellState(habitId: $0.habit.id ?? "",
                          title: $0.habit.title,
                          duration: Formatters.spentTime.string(from: $0.duration) ?? "")
            }
        }.share()

        let pushRecordList = inputs.selectHabit
            .withLatestFrom(Observable.combineLatest(cellState, inputs.selectDate) { ($0, $1) }) { (indexPath, args) -> RecordListViewModel in

                let (states, date) = args
                let habitId = states[indexPath.row].habitId
                return RecordListViewModel(habitId, date: date, service: Models.shared)
            }

        return .init(
            calendarRange: calendarRange,
            didChangeRecords: recordsMap.mapTo(()),
            cellState: cellState,
            deselectTableViewCell: inputs.selectHabit,
            pushRecordList: pushRecordList
        )
    }
}
