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
    public struct Inputs {}
    public struct Outputs {
        let calendarRange: Observable<DateRange>
    }

    private let disposeBag = DisposeBag()
    private let habitModel: HabitModelProtocol

    public init(_ service: CalendarViewModelService = Models.shared) {
        habitModel = service.habit
    }

    public func bind(_: Inputs) -> Outputs {
        let calendarRange: Observable<DateRange> = habitModel.oldestHabitRecord
            .compactMap {
                guard let oldest = $0?.createdAt else { return nil }
                guard let start = oldest.beginning(of: .month),
                    let end = Date().end(of: .month) else { return nil }
                return (start: start, end: end)
            }

        return .init(
            calendarRange: calendarRange
        )
    }
}
