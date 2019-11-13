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

private func scEventValue(_ type: String, action: String) -> [String: String] {
    return [AnalyticsParameterContentType: type,
            AnalyticsParameterItemID: action]
}

enum SelectContentEventValue: HasFirebaseEventParameter {
    // Manipulating habits
    case addedHabit
    case deletedHabit
    case editedHabit

    // Manipulating habit records
    case addedRecord(_ from: String)

    // calendars
    case tapCalendarDate
    case longPressCalendarDate

    // others
    case tapOthersButtonInRecordScreen

    var params: [String: Any] {
        switch self {
        case .addedHabit:
            return scEventValue("habit", action: "added")
        case .deletedHabit:
            return scEventValue("habit", action: "deleted")
        case .editedHabit:
            return scEventValue("habit", action: "edited")
        case let .addedRecord(from):
            return scEventValue("record", action: "add-from-\(from)")
        case .tapCalendarDate:
            return scEventValue("calendar", action: "tap")
        case .longPressCalendarDate:
            return scEventValue("calendar", action: "long-press")
        case .tapOthersButtonInRecordScreen:
            return scEventValue("others", action: "tap-others-button-in-record-screen")
        }
    }
}
