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
    @IBOutlet var tableView: UITableView!

    var viewModel: CalendarViewModel! = .init(Models.shared)

    private var calendarParameters = ConfigurationParameters(startDate: Date(), endDate: Date())
    private let didSelectDate = PublishSubject<Date>()

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.calendarDelegate = self
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.allowsMultipleSelection = false
        calendarView.allowsRangedSelection = false
        calendarView.alpha = 0

        let outputs = viewModel.bind(.init(
            selectDate: didSelectDate
        ))

        outputs.cellState
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { _, state, cell in
                cell.textLabel?.text = state.title
                cell.detailTextLabel?.text = state.duration
            }.disposed(by: disposeBag)

        outputs.calendarRange
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }

                self.calendarParameters = ConfigurationParameters(startDate: $0.start, endDate: $0.end)
                self.calendarView.calendarDataSource = self
                self.calendarView.reloadData {
                    self.calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: .top, extraAddedOffset: 0) {
                        self.calendarView.selectDates(from: Date(), to: Date())
                        self.calendarView.alpha = 1
                    }
                }

            }).disposed(by: disposeBag)

        outputs.didChangeRecords
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.calendarView.reloadData()
            }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.delegate = nil
    }

    private var selectedDate: Date?
}

extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt _: Date, cellState: CellState, indexPath _: IndexPath) {
        if let cell = cell as? CalendarDayCell {
            configureCell(cell, cellState: cellState)
        }
    }

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

    func calendar(_: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath _: IndexPath) {
        if let cell = cell as? CalendarDayCell {
            configureCell(cell, cellState: cellState)
            didSelectDate.onNext(date)
        }
    }

    func calendar(_: JTACMonthView, didDeselectDate _: Date, cell: JTACDayCell?, cellState: CellState, indexPath _: IndexPath) {
        if let cell = cell as? CalendarDayCell {
            configureCell(cell, cellState: cellState)
        }
    }

    private func configureCell(_ cell: CalendarDayCell, cellState: CellState) {
        guard let date = cellState.date.beginning(of: .day) else {
            print("warn: skip configure cell", cell, cellState)
            return
        }

        let numDots = viewModel.recordsMap[date]?.count ?? 0
        let state = CalendarDayCell.State(day: cellState.text,
                                          numOfDots: numDots,
                                          thisMonth: cellState.dateBelongsTo == .thisMonth,
                                          selected: cellState.isSelected)
        cell.state = state
    }
}

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_: JTACMonthView) -> ConfigurationParameters {
        return calendarParameters
    }
}

extension CalendarViewController: UITabBarControllerDelegate {
    func tabBarController(_: UITabBarController, didSelect viewController: UIViewController) {
        guard viewController == self else { return }

        // 画面が表示されてから delegate を set しているのでここが呼ばれるのは常に reselect

        let today = Date()
        calendarView.scrollToDate(today)
        calendarView.selectDates(from: today, to: today)
    }
}
