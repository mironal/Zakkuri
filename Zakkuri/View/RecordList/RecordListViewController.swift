//
//  RecordListViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/05.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class RecordListViewController: UIViewController {
    var viewModel: RecordListViewModel!

    @IBOutlet var tableView: UITableView!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init())

        outputs.title
            .asDriver(onErrorDriveWith: .never())
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)

        outputs.cellStates
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { _, state, cell in
                cell.textLabel?.text = state.title
                cell.detailTextLabel?.text = state.detail
            }.disposed(by: disposeBag)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
