//
//  FirebaseConstants.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/13.
//  Copyright © 2019 mironal. All rights reserved.
//

import FirebaseAnalytics
import Foundation

protocol HasFirebaseEventParameter {
    var params: [String: Any] { get }
}

extension Analytics {
    static func logEvent(_ name: String, value: HasFirebaseEventParameter) {
        logEvent(name, parameters: value.params)
    }
}

enum SelectContentEventValue: HasFirebaseEventParameter {
    case addedHabit
    case deletedHabit
    case editedHabit

    case addedRecord(_ from: String)

    var params: [String: Any] {
        switch self {
        case .addedHabit:
            return [AnalyticsParameterContentType: "habit",
                    AnalyticsParameterItemID: "added"]
        case .deletedHabit:
            return [AnalyticsParameterContentType: "habit",
                    AnalyticsParameterItemID: "deleted"]
        case .editedHabit:
            return [AnalyticsParameterContentType: "habit",
                    AnalyticsParameterItemID: "edited"]

        case let .addedRecord(from):
            return [AnalyticsParameterContentType: "record",
                    AnalyticsParameterItemID: "add-from-\(from)"]
        }
    }
}
