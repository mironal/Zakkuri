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
    enum NotificationType {
        case habitReminder(HabitID)

        static let Prefix = "dev.mironal.zakkuri.notification."
        static let HabitNotificationPrefix: String = "\(Prefix)_"
        var identifier: String {
            switch self {
            case let .habitReminder(id):
                return "\(NotificationType.HabitNotificationPrefix)\(id)"
            }
        }
    }

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

    private func scheduleReminder(for summary: HabitSummary) {
        let date = DateComponents(hour: 21, minute: 00)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = summary.habit.title
        content.body = "入力を忘れていませんか？"

        let request = UNNotificationRequest(identifier: NotificationType.habitReminder(summary.habit.id).identifier, content: content, trigger: trigger)

        center.add(request)
    }

    private func cancelPendingHabitNotification(_ complete: @escaping () -> Void) {
        center.getPendingNotificationRequests { [weak self] in

            let ns: [String] = $0.compactMap {
                $0.identifier.hasPrefix(NotificationType.HabitNotificationPrefix) ? $0.identifier : nil
            }
            self?.center.removePendingNotificationRequests(withIdentifiers: ns)
            complete()
        }
    }

    func scheduleReminderIfNeeded(_ habits: [HabitSummary]) {
        // 短期間に連続して呼び出されると不整合が発生しそうだが、今の所そこまでの頻度で呼び出されないと思うので問題が発生したら考える.

        cancelPendingHabitNotification { [weak self] in

            guard let self = self else { return }

            habits.filter {
                $0.habit.notify
                    && $0.spentTimeInDuration < $0.habit.targetTime
            }
            .forEach(self.scheduleReminder(for:))
        }
    }
}
