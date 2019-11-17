//
//  Models.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Firebase
import Foundation
import RxSwift

public struct Models {
    private static let disposeBag = DisposeBag()

    public static var shared: Models = {
        FirebaseApp.configure()

        let storage = FirestoreStorage(auth: Auth.auth(), firestore: Firestore.firestore())
        storage.migrate()
        storage.habits.count().subscribe(onNext: {
            Analytics.setUserProperty("\($0)", forName: "number_of_habits")
        }).disposed(by: disposeBag)
        storage.habits.count().subscribe(onNext: {
            Analytics.setUserProperty("\($0)", forName: "number_of_habitRecords")
        }).disposed(by: disposeBag)

        let habitModel = HabitModel(storage: storage)
        let notifyModel = NotifyModel()

        habitModel.habitsSummary
            .subscribe(onNext: notifyModel.scheduleReminderIfNeeded)
            .disposed(by: disposeBag)

        return .init(
            habit: habitModel,
            notify: notifyModel
        )
    }()

    public let habit: HabitModelProtocol
    public let notify: NotifyModelProtocol
}
