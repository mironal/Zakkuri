//
//  Formatter.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/02.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

struct Formatters {
    private init() {}

    public static let spentTime: DateComponentsFormatter = {
        let fmt = DateComponentsFormatter()
        fmt.allowedUnits = [.hour, .minute]
        fmt.unitsStyle = .short
        return fmt
    }()
}
