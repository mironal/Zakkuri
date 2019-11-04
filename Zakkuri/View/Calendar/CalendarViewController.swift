//
//  CalendarViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import JTAppleCalendar
import RxCocoa
import RxSwift
import SwifterSwift
import UIKit

class CalendarViewController: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!
    private let disposeBag = DisposeBag()

    var viewModel: CalendarViewModel! = .init(Models.shared)

    private var calendarParameters = ConfigurationParameters(startDate: Date(), endDate: Date())

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.scrollingMode = .stopAtEachCalendarFrame

        let outputs = viewModel.bind(.init())

        outputs.calendarRange.subscribe(onNext: { [weak self] in
            guard let self = self else { return }

            self.calendarParameters = ConfigurationParameters(startDate: $0.start, endDate: $0.end)
            self.calendarView.reloadData()

        }).disposed(by: disposeBag)

        outputs.didChangeRecords.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.calendarView.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_: JTACMonthView, willDisplay _: JTACDayCell, forItemAt _: Date, cellState _: CellState, indexPath _: IndexPath) {}

    func calendarSizeForMonths(_: JTACMonthView?) -> MonthSize? {
        return .init(defaultSize: 50)
    }

    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "MonthHeaderView", for: indexPath)

        if let header = header as? MonthHeaderView {
            header.monthLabel.text = Formatters.calendarHeader.string(from: range.start)
        }
        return header
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt _: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarDayCell", for: indexPath)
        if let cell = cell as? CalendarDayCell {
            configureCell(cell, cellState: cellState)
        }
        return cell
    }

    private func configureCell(_ cell: CalendarDayCell, cellState: CellState) {
        guard let date = cellState.date.beginning(of: .day) else { return }

        let numDots = viewModel.recordsMap[date]?.count ?? 0
        let state = CalendarDayCell.State(day: cellState.text, numOfDots: numDots, thisMonth: cellState.dateBelongsTo == .thisMonth)
        cell.state = state
    }
}

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_: JTACMonthView) -> ConfigurationParameters {
        return calendarParameters
    }
}
