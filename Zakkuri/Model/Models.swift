//
//  Models.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

public class Models {
    public static let shared = Models()

    private init() {
        let storage = UserDefaultsStorage()
        habit = HabitModel(storage: storage)
    }

    public var habit: HabitModelProtocol
}
