//
//  SummaryViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/13.
//  Copyright © 2019 mironal. All rights reserved.
//

import EmptyDataSet_Swift
import FloatingPanel
import RxCocoa
import RxDataSources
import RxSwift
import SwiftReorder
import UIKit

class SummaryViewController: UITableViewController {
    private let disposeBag = DisposeBag()
    public var viewModel = SummaryViewModel()
    @IBOutlet var addButton: UIBarButtonItem!

    private let deleteItemRelay = PublishRelay<IndexPath>()
    private let reorderRelay = PublishRelay<(srcRow: Int, destRow: Int)>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapAdd: addButton.rx.tap.asObservable(),
            selectItem: tableView.rx.itemSelected.asObservable().do(afterNext: { [weak self] in self?.tableView.deselectRow(at: $0, animated: true) }),
            deleteItem: deleteItemRelay.asObservable(),
            reorder: reorderRelay.asObservable()
        ))

        tableView.dataSource = nil
        tableView.emptyDataSetSource = self
        tableView.reorder.delegate = self

        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfSummaryCellState>(configureCell: { (_, tableView, indexPath, state) -> UITableViewCell in

            if let spacer = tableView.reorder.spacerCell(for: indexPath) {
                return spacer
            }

            let cell = tableView.dequeueReusableCell(withClass: SummaryCell.self, for: indexPath)

            cell.state = state
            return cell
        })

        outputs.habitCells
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        outputs.showRecordView
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                guard let vc = RecordViewController.instantiateFromStoryboard() else { return }
                vc.viewModel = $0

                let fpc = FloatingPanelController(wrap: vc)
                self.present(fpc, animated: true)

            }).disposed(by: disposeBag)

        outputs.showHabitForm.asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let vc = HabitFormViewController.instantiateFromStoryboard() else { return }

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

extension SummaryViewController: EmptyDataSetSource {
    func title(forEmptyDataSet _: UIScrollView) -> NSAttributedString? {
        return .init(string: "まだ習慣がありません")
    }

    func description(forEmptyDataSet _: UIScrollView) -> NSAttributedString? {
        return .init(string: "右上の + ボタンから1つ目の週間を追加しましょう！")
    }
}

extension SummaryViewController: TableViewReorderDelegate {
    func tableView(_: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        reorderRelay.accept((srcRow: sourceIndexPath.row, destRow: destinationIndexPath.row))
    }
}
