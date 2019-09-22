//
//  RecordViewController.swift
//  laid-back
//
//  Created by mironal on 2019/09/15.
//  Copyright © 2019 mironal. All rights reserved.
//

import FloatingPanel
import RxCocoa
import RxSwift
import UIKit

class RecordViewController: UIViewController {
    @IBOutlet var doneButton: UIButton!

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var titleLabel: UILabel!

    let changeDurationRelay = PublishRelay<TimeInterval>()
    @IBOutlet var timePicker: UIDatePicker! {
        didSet {
            // Layout が走った後にセットしないとずれてしまう...
            DispatchQueue.main.async {
                self.timePicker.countDownDuration = 30 * 60
                // 初期化前に subscribe すると謎の値が入ってくるので初期化してからのイベントだけ伝搬するようにした.
                self.timePicker.rx.countDownDuration.bind(to: self.changeDurationRelay).disposed(by: self.disposeBag)
            }
        }
    }

    public var viewModel: RecordViewModel!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapDone: doneButton.rx.tap.asObservable(),
            tapClose: closeButton.rx.tap.asObservable(),
            changeDuration: changeDurationRelay.asObservable()
        ))

        outputs.title
            .asDriver(onErrorJustReturn: "")
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        outputs.dismiss
            .asSignal(onErrorJustReturn: ())
            .emit(onNext: { [weak self] in
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}

private class FPLayout: FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition {
        return .half
    }

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .half:
            return 300
        default:
            return nil
        }
    }

    var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    func backdropAlphaFor(position _: FloatingPanelPosition) -> CGFloat {
        return 0.3
    }
}

extension RecordViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_: FloatingPanelController, layoutFor _: UITraitCollection) -> FloatingPanelLayout? {
        return FPLayout()
    }
}
