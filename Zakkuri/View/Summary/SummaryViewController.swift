//
//  SummaryViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/13.
//  Copyright © 2019 mironal. All rights reserved.
//

import FloatingPanel
import RxCocoa
import RxSwift
import UIKit

class SummaryViewController: UITableViewController {
    private let disposeBag = DisposeBag()
    public var viewModel = SummaryViewModel()
    @IBOutlet var addButton: UIBarButtonItem!

    private let deleteItemRelay = PublishRelay<IndexPath>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapAdd: addButton.rx.tap.asObservable(),
            selectItem: tableView.rx.itemSelected.asObservable().do(afterNext: { [weak self] in self?.tableView.deselectRow(at: $0, animated: true) }),
            deleteItem: deleteItemRelay.asObservable()
        ))

        tableView.dataSource = nil

        outputs.habitCells.bind(to: tableView.rx.items(cellIdentifier: "SummaryCell", cellType: SummaryCell.self)) { _, state, cell in

            cell.state = state

        }.disposed(by: disposeBag)

        outputs.showRecordView
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }

                guard let vc = UIStoryboard(name: "RecordViewController", bundle: .main).instantiateViewController(withClass: RecordViewController.self) else { return }
                vc.viewModel = $0

                let fpc = FloatingPanelController(wrap: vc)
                self.present(fpc, animated: true)

            }).disposed(by: disposeBag)

        outputs.showHabitForm.asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let vc = UIStoryboard(name: "HabitFormViewController", bundle: .main).instantiateViewController(withClass: HabitFormViewController.self) else { return }

                vc.viewModel = $0

                let nav = UINavigationController(rootViewController: vc)
                self?.present(nav, animated: true)
            }).disposed(by: disposeBag)
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, success in
            guard let self = self else { return }

            UIAlertController.confirmDelete()(self).subscribe(onNext: {
                switch $0 {
                case .cancel:
                    success(false)
                case .delete:
                    self.deleteItemRelay.accept(indexPath)
                    success(true)
                }
            }).disposed(by: self.disposeBag)
        }

        delete.backgroundColor = Theme.defailt.accentColor

        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension HabitSummary: SummaryCellState {
    public var title: String {
        return habit.title
    }

    public var goalSpan: GoalSpan {
        return habit.goalSpan
    }

    public var progress: Float {
        return Float(spentTimeInDuration / habit.targetTime)
    }
}
