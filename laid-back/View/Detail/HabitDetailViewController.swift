//
//  HabitDetailViewController.swift
//  laid-back
//
//  Created by mironal on 2019/09/22.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class HabitDetailViewController: UITableViewController {
    @IBOutlet var closeButton: UIBarButtonItem!
    private let disposeBag = DisposeBag()

    public override func viewDidLoad() {
        super.viewDidLoad()

        closeButton.rx.tap.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
}
