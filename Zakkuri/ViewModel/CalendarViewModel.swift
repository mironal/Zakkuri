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
    public typealias HabitSheetProps = (date: Date, subject: PublishSubject<(date: Date, habit: HabitID)>, habits: [(habitId: HabitID, title: String)])

    public struct Inputs {
        let selectDate: Observable<Date>
        let longPressDate: Observable<Date>
        let selectHabit: Observable<IndexPath>
    }

    public struct Outputs {
        let calendarRange: Observable<DateRange>
        let didChangeRecords: Observable<Void>
        let cellState: Observable<[CellState]>
        let deselectTableViewCell: Observable<IndexPath>
        let pushRecordList: Observable<RecordListViewModel>
        let showHabitsSheet: Observable<HabitSheetProps>
        let showRecordView: Observable<RecordViewModel>
    }

    private let disposeBag = DisposeBag()
    private let habitModel: HabitModelProtocol

    public private(set) var recordsMap: RecordsMap = [:]

    public init(_ service: CalendarViewModelService = Models.shared) {
        habitModel = service.habit
    }

    public func bind(_ inputs: Inputs) -> Outputs {
        let calendarRange: Observable<DateRange> = habitModel.visibleCalendarRange
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

        let selectHabitSubject = PublishSubject<(date: Date, habit: HabitID)>()

        let reselectWithLongPress = inputs.longPressDate
            .withLatestFrom(inputs.selectDate) { ($0, $1) }
            .filterMap { $0.0 == $0.1 ? .map($0.0) : .ignore }
            .share()

        let showHabitsSheet: Observable<HabitSheetProps> = reselectWithLongPress
            .withLatestFrom(habitModel.habitsSummary) { (date: $0, habits: $1) }
            .map {
                let habits = $0.habits.map { (habitId: $0.habit.id ?? "ありえん", title: $0.title) }
                return (date: $0.date, subject: selectHabitSubject, habits: habits)
            }

        let showRecordView: Observable<RecordViewModel> = selectHabitSubject
            .map {
                // 今日の場合は createdAt を nil にして現在時刻が記録されるようにする
                let createdAt = $0.date.isInToday ? nil : $0.date
                return RecordViewModel(habitId: $0.habit, createdAt: createdAt, service: Models.shared)
            }

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
            pushRecordList: pushRecordList,
            showHabitsSheet: showHabitsSheet,
            showRecordView: showRecordView
        )
    }
}
