//
//  HabitInputViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/18.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class HabitInputViewController: UIViewController {
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var textField: UITextField!

    var viewModel: HabitInputViewModel!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(tapCancel: cancelButton.rx.tap.asObservable(),
                                           tapAdd: addButton.rx.tap.asObservable(),
                                           changeText: textField.rx.text.orEmpty.asObservable()))

        outputs.dismiss.subscribe(onNext: {
            self.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }
}
