//
//  HabitFormViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

private extension HabitFormViewModel.TappedItem {
    init?(indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            self = .title
        case (1, 0):
            self = .span
        case (1, 1):
            self = .goalTime
        case (_, _):
            return nil
        }
    }
}

class HabitFormViewController: UITableViewController {
    public var viewModel: HabitFormViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!

    @IBOutlet var spanCell: UITableViewCell!
    @IBOutlet var timeCell: UITableViewCell!

    @IBOutlet var readableCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self

        let selectSpanRelay = PublishRelay<GoalSpan>()
        let selectGoalTimeRelay = PublishRelay<TimeInterval>()

        let tapItem = tableView.rx.itemSelected
            .do(onNext: { [weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
            .compactMap { HabitFormViewModel.TappedItem(indexPath: $0) }

        func reloadTableView(at indexPath: IndexPath) {
            if HabitFormViewModel.TappedItem(indexPath: indexPath) != .title {
                tableView.reloadData()
                titleTextField.becomeFirstResponder()
            }
        }

        let outputs = viewModel.bind(.init(
            changeTitle: titleTextField.rx.text.orEmpty.asObservable(),
            tapCancel: cancelButton.rx.tap.asObservable(),
            tapSave: saveButton.rx.tap.asObservable(),
            tapItem: tapItem,
            selectSpan: selectSpanRelay.asObservable(),
            selectGoalTime: selectGoalTimeRelay.asObservable()
        ))

        func startEditing() {
            titleTextField.becomeFirstResponder()
        }

        outputs.canSave
            .asDriver(onErrorDriveWith: .never())
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        outputs.startTitleEditing.asSignal(onErrorSignalWith: .never())
            .emit(onNext: startEditing).disposed(by: disposeBag)

        outputs.dismiss
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in self?.dismiss(animated: true) })
            .disposed(by: disposeBag)

        outputs.span.asDriver(onErrorDriveWith: .never())
            .map { Optional($0.localizedString) }
            .do(afterNext: { _ in reloadTableView(at: .init(row: 0, section: 1)) })
            .drive(spanCell.detailTextLabel!.rx.text)
            .disposed(by: disposeBag)

        outputs.goalTime
            .compactMap { Habit.timeFormatter.string(from: $0) }
            .asDriver(onErrorDriveWith: .never())
            .do(afterNext: { _ in reloadTableView(at: .init(row: 1, section: 1)) })
            .drive(timeCell.detailTextLabel!.rx.text)
            .disposed(by: disposeBag)

        outputs.readableString.asDriver(onErrorDriveWith: .never())
            .do(afterNext: { _ in reloadTableView(at: .init(row: 0, section: 2)) })
            .drive(readableCell.textLabel!.rx.text)
            .disposed(by: disposeBag)

        func showSelectSpan() {
            let sheet = UIAlertController(title: nil, message: "期間を選んでください", preferredStyle: .actionSheet)

            GoalSpan.allCases.forEach { span in
                sheet.addAction(.init(title: span.localizedString, style: .default, handler: { _ in
                    selectSpanRelay.accept(span)
                }))
            }

            sheet.addAction(.init(title: "Cancel", style: .cancel))

            present(sheet, animated: true)
        }

        outputs.showSelectSpan
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: showSelectSpan)
            .disposed(by: disposeBag)

        func showTimePicker() {
            let alert = UIAlertController(title: nil, message: "時間を入力(h)", preferredStyle: .alert)
            alert.addTextField {
                $0.keyboardType = .decimalPad
            }

            alert.addAction(.init(title: "OK", style: .default, handler: { _ in

                guard let tf = alert.textFields?.first else { return }

                guard let hour = tf.text.flatMap(Int.init) else { return }

                let second: TimeInterval = Double(hour * 60 * 60)
                selectGoalTimeRelay.accept(second)
            }))

            present(alert, animated: true)
        }

        outputs.showTimePicker
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: showTimePicker)
            .disposed(by: disposeBag)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension HabitFormViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_: UITextField) -> Bool {
        return true
    }
}
