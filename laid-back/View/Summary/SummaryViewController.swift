//
//  SummaryViewController.swift
//  laid-back
//
//  Created by mironal on 2019/09/13.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import SwifterSwift
import UIKit

class SummaryViewController: UITableViewController {
    private let disposeBag = DisposeBag()
    public var viewModel = SummaryViewModel()
    @IBOutlet var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapAdd: addButton.rx.tap.asObservable()
        ))

        outputs.habits.bind(to: tableView.rx.items(cellIdentifier: "SummaryCell", cellType: SummaryCell.self)) { _, habit, cell in

            cell.state = SummaryCellState(habit: habit)

        }.disposed(by: disposeBag)

        outputs.showGoalForm.asSignal(onErrorSignalWith: .never())
            .emit(onNext: { [weak self] in
                guard let vc = UIStoryboard(name: "HabitFormViewController", bundle: .main).instantiateViewController(withClass: HabitFormViewController.self) else { return }

                vc.viewModel = $0

                let nav = UINavigationController(rootViewController: vc)
                self?.present(nav, animated: true)
            }).disposed(by: disposeBag)
    }
}
