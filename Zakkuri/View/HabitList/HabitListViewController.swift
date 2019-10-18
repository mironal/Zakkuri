//
//  HabitListViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/15.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class HabitListViewController: UIViewController {
    @IBOutlet var label: UILabel!
    @IBOutlet var addButton: UIButton!

    var viewModel: HabitListViewModel! = .init()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapAdd: addButton.rx.tap.asObservable()
        ))

        outputs.success
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                let alert = UIAlertController(title: nil, message: "保存しました", preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: { _ in

                }))

                self.present(alert, animated: true)

            }).disposed(by: disposeBag)

        outputs
            .showInput
            .asSignal(onErrorSignalWith: .never())
            .emit(onNext: {
                // main thread で実行される

                guard let vc = UIStoryboard(name: "HabitInputViewController", bundle: .main).instantiateInitialViewController() as? HabitInputViewController else {
                    fatalError("HabitInputViewController がない")
                }

                vc.viewModel = $0

                let nav = UINavigationController(rootViewController: vc)

                self.present(nav, animated: true)

            }).disposed(by: disposeBag)
    }
}
