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
    public typealias DateRange = (start: Date, end: Date)
    public typealias RecordsMap = [Date: [Habit]]

    public struct Inputs {
        let selectDate: Observable<Date>
    }

    public struct Outputs {
        let calendarRange: Observable<DateRange>
        let didChangeRecords: Observable<Void>
        let cellState: Observable<[String]>
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
            $0.mapKeysAndValues { arg -> (Date, [Habit]) in

                let (key, value) = arg

                let habits = value.keys.map { $0 }
                return (key, habits)
            }
        }.do(onNext: { self.recordsMap = $0 })
            .share()

        let cellState = inputs.selectDate.withLatestFrom(recordsMap) { (date, records) -> [String] in
            let habits = records[date] ?? []
            return habits.map { $0.title }
        }

        return .init(
            calendarRange: calendarRange,
            didChangeRecords: recordsMap.mapTo(()),
            cellState: cellState
        )
    }
}
