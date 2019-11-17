//
//  PreviewVideoPlayerViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/17.
//  Copyright © 2019 mironal. All rights reserved.
//

import FirebaseStorage
import Foundation
import RxCocoa
import RxSwift

func appPreviewVideoCachePath(version: Int) -> String {
    return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        .appendingPathComponent("AppPreview")
        .appendingPathComponent("v\(version).mp4")
}

private let Version: Int = 0

class PreviewVideoPlayerViewModel {
    public enum Progress {
        case progress(Double)
        case complate(URL)
    }

    struct Inputs {
        let tapPlay: Observable<Void>
        let tapClose: Observable<Void>
    }

    struct Outputs {
        let progress: Driver<Float>
        let progressIsHidden: Driver<Bool>
        let playButtonIsHidden: Driver<Bool>
        let videoURL: Driver<URL>
        let isPlaying: Signal<Bool>
        let dismiss: Signal<Void>
    }

    func bind(_ inputs: Inputs) -> Outputs {
        let download = downloadVideoIfNeeded().share()

        let progress: Observable<Float> = download.compactMap {
            if case let .progress(value) = $0 {
                return Float(value)
            }
            return nil
        }.startWith(0)

        let videoURL: Observable<URL> = download.compactMap {
            if case let .complate(url) = $0 {
                return url
            }
            return nil
        }.share()

        let isPlaying = inputs.tapPlay.withLatestFrom(videoURL).mapTo(true)
        let progressIsHidden = videoURL.mapTo(true).startWith(false)

        let playButtonIsHidden = Observable.combineLatest(isPlaying, progressIsHidden)
            .map { $0 || !$1 }

        return .init(
            progress: progress.asDriver(onErrorDriveWith: .never()),
            progressIsHidden: progressIsHidden.asDriver(onErrorDriveWith: .never()),
            playButtonIsHidden: playButtonIsHidden.asDriver(onErrorDriveWith: .never()),
            videoURL: videoURL.asDriver(onErrorDriveWith: .never()),
            isPlaying: isPlaying.asSignal(onErrorSignalWith: .never()),
            dismiss: inputs.tapClose.asSignal(onErrorSignalWith: .never())
        )
    }
}

private func downloadVideoIfNeeded() -> Observable<PreviewVideoPlayerViewModel.Progress> {
    return .create { observable in

        let cacheFilePath = appPreviewVideoCachePath(version: Version)

        if FileManager.default.fileExists(atPath: cacheFilePath) {
            observable.onNext(.complate(URL(fileURLWithPath: cacheFilePath)))
            observable.onCompleted()
            return Disposables.create()
        }

        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: cacheFilePath.deletingLastPathComponent, isDirectory: &isDirectory)

        if !exists || !isDirectory.boolValue {
            do {
                try FileManager.default.createDirectory(atPath: cacheFilePath.deletingLastPathComponent, withIntermediateDirectories: true)
            } catch {
                observable.onError(error)
                return Disposables.create()
            }
        }

        let ref = Storage.storage().reference(withPath: "public/Zakkuri_AppPreview_low.mp4")
        let task = ref.write(toFile: URL(fileURLWithPath: cacheFilePath)) { url, error in

            if let error = error {
                observable.onError(error)
                return
            }

            guard let url = url else { return }

            observable.onNext(.complate(url))
            observable.onCompleted()
        }

        let taskObserver = task.observe(.progress) {
            let progress = $0.progress.map { $0.fractionCompleted } ?? 0
            observable.onNext(.progress(progress))
        }

        return Disposables.create {
            task.removeObserver(withHandle: taskObserver)
            task.cancel()
        }
    }
}
