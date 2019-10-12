//
//  GoalSpan.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

public enum GoalSpan: Int, CaseIterable, Codable {
    case aDay, aWeek, aMonth
    var localizedString: String {
        switch self {
        case .aDay: return "24 hours"
        case .aWeek: return "7 days"
        case .aMonth: return "30 days"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .aDay: return 86400
        case .aWeek: return 604_800
        case .aMonth: return 2_592_000
        }
    }
}
