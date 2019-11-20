//
//  PreviewVideoPlayerViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/17.
//  Copyright © 2019 mironal. All rights reserved.
//

import AVFoundation
import FirebaseStorage
import RxCocoa
import RxSwift
import SwifterSwift
import UIKit

final class PlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

extension Reactive where Base: PlayerView {
    var videoURL: Binder<URL> {
        return Binder(base) { $0.player = AVPlayer(url: $1) }
    }

    var isPlaying: Binder<Bool> {
        return Binder(base) { $1 ? $0.player?.play() : $0.player?.pause() }
    }
}

class PreviewVideoPlayerViewController: UIViewController {
    @IBOutlet var playerView: PlayerView! {
        didSet {
            playerView.cornerRadius = 16
        }
    }

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var playButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 60)
            let image = UIImage(systemName: "play.circle", withConfiguration: config)
            playButton.setImage(image, for: .normal)
        }
    }

    var viewModel: PreviewVideoPlayerViewModel = .init()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let outputs = viewModel.bind(.init(
            tapPlay: playButton.rx.tap.asObservable(),
            tapClose: closeButton.rx.tap.asObservable()
        ))

        outputs.dismiss
            .emit(onNext: { [weak self] in
                self?.dismiss(animated: true)
            }).disposed(by: disposeBag)

        outputs.progress
            .drive(progressView.rx.progress)
            .disposed(by: disposeBag)

        outputs.progressIsHidden
            .drive(progressView.rx.isHidden)
            .disposed(by: disposeBag)

        outputs.playButtonIsHidden
            .drive(playButton.rx.isHidden)
            .disposed(by: disposeBag)

        outputs.videoURL
            .drive(playerView.rx.videoURL)
            .disposed(by: disposeBag)

        outputs.isPlaying
            .emit(to: playerView.rx.isPlaying)
            .disposed(by: disposeBag)
    }

    private func startPlay(_ url: URL) {
        let player = AVPlayer(url: url)
        playerView.player = player
        player.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerView.player = nil
    }
}
