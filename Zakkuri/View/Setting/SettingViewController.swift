//
//  SettingViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/20.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import RxSwiftExt
import UIKit

extension Observable where Element == SettingViewController.Row {
    func filter(row: SettingViewController.Row) -> RxSwift.Observable<Void> {
        return filter { $0 == row }.mapTo(())
    }
}

class SettingViewController: UITableViewController {
    enum Row {
        case reminderTime
        case getHowTo

        init?(_ indexPath: IndexPath) {
            guard let section = Section(rawValue: indexPath.section) else { return nil }
            self = section.rows[indexPath.row]
        }
    }

    enum Section: Int, CaseIterable {
        case notification
        case others

        var rows: [Row] {
            switch self {
            case .notification:
                return [.reminderTime]
            case .others:
                return [.getHowTo]
            }
        }
    }

    var viewModel: SettingViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        let didSelectRow = tableView.rx.itemSelected
            .compactMap { Row($0) }
            .asObservable().share()

        let outputs = viewModel.bind(.init(
            tapReminderTimeCell: didSelectRow.filter(row: .reminderTime),
            tapGetHowToCell: didSelectRow.filter(row: .getHowTo),
            tapDone: doneButton.rx.tap.asObservable()
        ))

        outputs.showHowTo.emit(onNext: { [weak self] in
            guard let vc = PreviewVideoPlayerViewController.instantiateFromStoryboard() else { return }
            vc.viewModel = $0
            self?.present(vc, animated: true)

        }).disposed(by: disposeBag)

        outputs.dismiss.emit(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
}
