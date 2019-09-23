//
//  HabitDetailViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/22.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class HabitDetailViewController: UITableViewController {
    public var viewModel: HabitDetailViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet var closeButton: UIBarButtonItem!

    public override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapClose: closeButton.rx.tap.asObservable()
        ))

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .abbreviated

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "YYYY/MM/dd"

        outputs.habitRecords.bind(to: tableView.rx.items(cellIdentifier: "cell")) { _, record, cell in
            cell.textLabel?.text = formatter.string(from: record.duration)
            cell.detailTextLabel?.text = dateFormatter.string(from: record.createdAt)
        }.disposed(by: disposeBag)

        outputs.dismiss.asSignal(onErrorJustReturn: ())
            .emit(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}
