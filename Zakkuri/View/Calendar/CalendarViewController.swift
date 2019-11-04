//
//  CalendarViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import JTAppleCalendar
import UIKit

class CalendarViewController: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.scrollingMode = .stopAtEachCalendarFrame
    }
}

extension CalendarViewController: JTACMonthViewDelegate {
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

    func calendar(_: JTACMonthView, willDisplay _: JTACDayCell, forItemAt _: Date, cellState _: CellState, indexPath _: IndexPath) {}

    func calendar(_ calendar: JTACMonthView, cellForItemAt _: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarDayCell", for: indexPath)

        if let cell = cell as? CalendarDayCell {
            configureCell(cell, state: cellState)
        }

        return cell
    }

    private func configureCell(_ cell: CalendarDayCell, state: CellState) {
        cell.dayLabel.text = state.text

        if state.dateBelongsTo == .thisMonth {
            cell.dayLabel.textColor = .black
        } else {
            cell.dayLabel.textColor = .gray
        }
    }
}

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
}
