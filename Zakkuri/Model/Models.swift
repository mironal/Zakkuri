//
//  Models.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

public struct Models {
    public static let shared: Models = {
        let storage = UserDefaultsStorage()
        let habitModel = HabitModel(storage: storage)
        let notifyModel = NotifyModel()
        return .init(habit: habitModel,
                     notify: notifyModel)
    }()

    public let habit: HabitModelProtocol
    public let notify: NotifyModelProtocol
}
