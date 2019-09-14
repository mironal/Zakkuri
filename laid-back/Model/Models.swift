//
//  Models.swift
//  laid-back
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

public class Models {
    public static let shared = Models()

    private init() {
        habit = HabitModel()
    }

    public var habit: HabitModelProtocol
}
