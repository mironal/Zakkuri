//
//  NotifyModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import UserNotifications

public protocol NotifyModelProtocol {
    var deniedNotification: Observable<Bool> { get }
    func requestAuthorization() -> Single<Bool>

    func applicationWillEnterForeground()
}

class NotifyModel: NotifyModelProtocol {
    private let center = UNUserNotificationCenter.current()

    private func reloadNotificationSettings() {
        center.getNotificationSettings { [weak self] in
            self?.deniedNotificationSubject.onNext($0.authorizationStatus == .denied)
        }
    }

    private let deniedNotificationSubject: ReplaySubject<Bool> = ReplaySubject<Bool>.create(bufferSize: 1)

    init() {
        reloadNotificationSettings()
    }

    var deniedNotification: Observable<Bool> {
        return deniedNotificationSubject
    }

    public func applicationWillEnterForeground() {
        reloadNotificationSettings()
    }

    func requestAuthorization() -> Single<Bool> {
        let center = self.center

        return .create { single -> Disposable in

            center.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] granted, error in
                self?.reloadNotificationSettings()
                if let error = error {
                    single(.error(error))
                    return
                }
                single(.success(granted))
            }

            return Disposables.create()
        }
    }
}
