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

class RecordToDetailTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool

    init(_ isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            guard let from = transitionContext.viewController(forKey: .from) as? FloatingPanelController,
                let to = transitionContext.viewController(forKey: .to) else {
                return
            }
            present(from: from, to: to, transitionContext: transitionContext)
        } else {
            guard let to = transitionContext.viewController(forKey: .to) as? FloatingPanelController,
                let from = transitionContext.viewController(forKey: .from) else {
                return
            }
            dismiss(from: from, to: to, transitionContext: transitionContext)
        }
    }

    private func present(from: FloatingPanelController, to: UIViewController, transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView

        // RecordViewController の位置からにゅっと上に出す
        container.addSubview(to.view)
        to.view.frame = from.surfaceView.frame

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseIn], animations: {
            to.view.frame = from.view.frame
            from.view.alpha = 0
        }) {
            from.view.alpha = 1
            transitionContext.completeTransition($0)
        }
    }

    private func dismiss(from: UIViewController, to: FloatingPanelController, transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        container.addSubview(to.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            from.view.frame = to.surfaceView.frame
            from.view.alpha = 0.8
        }) {
            transitionContext.completeTransition($0)
        }
    }
}

class RecordViewController: UIViewController {
    @IBOutlet var doneButton: UIButton!

    @IBOutlet var nextButton: UIButton!
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
            tapNext: nextButton.rx.tap.asObservable(),
            changeDuration: changeDurationRelay.asObservable()
        ))

        outputs.title
            .asDriver(onErrorJustReturn: "")
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        outputs.showDetail
            .asSignal(onErrorJustReturn: ())
            .emit(onNext: { [weak self] in

                guard let self = self else { return }

                guard let detail = UIStoryboard(name: "HabitDetailViewController", bundle: .main).instantiateViewController(withClass: HabitDetailViewController.self) else { return }

                let nav = UINavigationController(rootViewController: detail)
                nav.transitioningDelegate = self
                self.transitioningDelegate = self

                self.present(nav, animated: true)
            }).disposed(by: disposeBag)

        outputs.dismiss
            .asSignal(onErrorJustReturn: ())
            .emit(onNext: { [weak self] in
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}

extension RecordViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RecordToDetailTransition(true)
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RecordToDetailTransition(false)
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
    func floatingPanelDidEndRemove(_: FloatingPanelController) {
        print("floatingPanelDidEndRemove")
    }

    func floatingPanel(_: FloatingPanelController, layoutFor _: UITraitCollection) -> FloatingPanelLayout? {
        return FPLayout()
    }
}
