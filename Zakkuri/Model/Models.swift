//
//  Models.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/18.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

struct Models {
    public static let shared: Models = {
        .init(habitModel: HabitModel())
    }()

    let habitModel: HabitModelProtocol
}
