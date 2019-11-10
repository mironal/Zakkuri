//
//  CalendarViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import EmptyDataSet_Swift
import FloatingPanel
import JTAppleCalendar
import RxCocoa
import RxGesture
import RxSwift
import SwifterSwift
import UIKit

class CalendarViewController: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!
    private let disposeBag = DisposeBag()
    @IBOutlet var tableView: UITableView!

    @IBOutlet var borderView: UIView!
    var viewModel: CalendarViewModel! = .init(Models.shared)

    private var calendarParameters = ConfigurationParameters(startDate: Date(), endDate: Date())
    private let didSelectDate = PublishSubject<Date>()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.emptyDataSetSource = self

        calendarView.calendarDelegate = self
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.allowsMultipleSelection = false
        calendarView.allowsRangedSelection = false
        calendarView.alpha = 0

        let longPressDate: Observable<Date> = calendarView.rx
            .longPressGesture()
            .compactMap {
                guard $0.state == .began else { return nil }
                guard let collectionView = $0.view as? JTACMonthView else { return nil }

                let point = $0.location(in: collectionView)
                let state = collectionView.cellStatus(at: point)
                return state?.date
            }

        let outputs = viewModel.bind(.init(
            selectDate: didSelectDate,
            longPressDate: longPressDate,
            selectHabit: tableView.rx.itemSelected.asObservable()
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
                    let date = Date()
                    self.updateTitle(date)
                    self.calendarView.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: .top, extraAddedOffset: 0) {
                        self.calendarView.selectDates([date])
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

        outputs.deselectTableViewCell.asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.tableView.deselectRow(at: $0, animated: true)
            }).disposed(by: disposeBag)

        outputs.pushRecordList
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: {
                guard let vc = UIStoryboard(name: "RecordListViewController", bundle: .main).instantiateViewController(withClass: RecordListViewController.self) else { return }
                vc.viewModel = $0
                self.navigationController?.pushViewController(vc)
            }).disposed(by: disposeBag)

        outputs.showHabitsSheet
            .asSignal(onErrorSignalWith: .never())
            .map { props -> UIAlertController in

                let sheet = UIAlertController(title: "記録を追加", message: nil, preferredStyle: .actionSheet)

                props.habits.forEach { h in
                    sheet.addAction(UIAlertAction(title: h.title, style: .default) { _ in
                        props.subject.onNext(h.habitId)
                    })
                }
                sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                return sheet
            }

            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.present($0, animated: true)
            }).disposed(by: disposeBag)

        outputs.showRecordView
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                guard let vc = UIStoryboard(name: "RecordViewController", bundle: .main).instantiateViewController(withClass: RecordViewController.self) else { return }

                vc.viewModel = $0

                let fpc = FloatingPanelController(wrap: vc)
                self.present(fpc, animated: true)
            }).disposed(by: disposeBag)
    }

    func updateTitle(_ date: Date) {
        navigationItem.title = Formatters.calendarHeader.string(from: date)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.delegate = nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        borderView.layer.sublayers = nil
        borderView.layer.addBorder(edge: .bottom, color: .lightGray, thickness: 1)
    }

    private var selectedDate: Date?
}

extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt _: Date, cellState: CellState, indexPath _: IndexPath) {
        if let cell = cell as? CalendarDayCell {
            configureCell(cell, cellState: cellState)
        }
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

    func calendar(_: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let date = visibleDates.monthDates.first?.date {
            updateTitle(date)
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
        guard let nav = viewController as? UINavigationController else {
            return
        }

        if nav.visibleViewController == self {
            // 画面が表示されてから delegate を set しているのでここが呼ばれるのは常に reselect

            let today = Date()
            calendarView.scrollToDate(today)
            calendarView.selectDates(from: today, to: today)
        }
    }
}

extension CalendarViewController: EmptyDataSetSource {
    func title(forEmptyDataSet _: UIScrollView) -> NSAttributedString? {
        return .init(string: "日付を長押しで記録を追加できます.")
    }
}
