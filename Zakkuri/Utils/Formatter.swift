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

    public static let dateOnly: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .none
        return fmt
    }()

    public static let recordingDate: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()

    public static let calendarHeader: DateFormatter = {
        let template = DateFormatter.dateFormat(fromTemplate: "yMMMM", options: 0, locale: Locale.current)
        let fmt = DateFormatter()
        fmt.dateFormat = template
        return fmt
    }()
}
