//
//  HabitSummary.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

public struct HabitSummary {
    let habit: Habit
    let spentTimeInDuration: TimeInterval

    var summary: String {
        let fmt = DateComponentsFormatter()
        fmt.allowedUnits = [.hour, .minute]
        fmt.unitsStyle = .short

        return "You spent \(fmt.string(from: spentTimeInDuration) ?? "0") in the last \(habit.goalSpan.localizedString)"
    }
}
