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

        let habitModel = HabitModel(storage: storage)
        let notifyModel = NotifyModel()

        habitModel.habitsSummary.subscribe(onNext: {
            notifyModel.scheduleReminderIfNeeded($0)
        }).disposed(by: disposeBag)

        return .init(
            habit: habitModel,
            notify: notifyModel
        )
    }()

    public let habit: HabitModelProtocol
    public let notify: NotifyModelProtocol
}
