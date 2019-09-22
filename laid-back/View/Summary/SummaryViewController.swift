//
//  SummaryViewController.swift
//  laid-back
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
    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapAdd: addButton.rx.tap.asObservable(),
            selectItem: tableView.rx.itemSelected.asObservable().do(afterNext: { [weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
        ))

        outputs.habits.bind(to: tableView.rx.items(cellIdentifier: "SummaryCell", cellType: SummaryCell.self)) { _, summary, cell in

            cell.state = SummaryCellState(summary: summary)

        }.disposed(by: disposeBag)

        outputs.showRecordView
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: {
                guard let vc = UIStoryboard(name: "RecordViewController", bundle: .main).instantiateViewController(withClass: RecordViewController.self) else { return }
                vc.viewModel = $0

                let fpc = FloatingPanelController(delegate: vc)
                fpc.surfaceView.shadowHidden = false
                (fpc.surfaceView as UIView).cornerRadius = 9
                (fpc.surfaceView as UIView).borderWidth = 1.0 / self.traitCollection.displayScale
                (fpc.surfaceView as UIView).borderColor = UIColor.black.withAlphaComponent(0.2)
                fpc.backdropView.alpha = 1
                fpc.isRemovalInteractionEnabled = true

                fpc.set(contentViewController: vc)
                self.present(fpc, animated: true)

            }).disposed(by: disposeBag)

        outputs.showGoalForm.asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let vc = UIStoryboard(name: "HabitFormViewController", bundle: .main).instantiateViewController(withClass: HabitFormViewController.self) else { return }

                vc.viewModel = $0

                let nav = UINavigationController(rootViewController: vc)
                self?.present(nav, animated: true)
            }).disposed(by: disposeBag)
    }
}
