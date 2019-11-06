//
//  Habit.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import FirebaseFirestoreSwift
import Foundation

public typealias HabitID = String

public struct Habit: Codable, Equatable, Hashable {
    @DocumentID public var id: HabitID?
    public let title: String
    public let goalSpan: GoalSpan
    public let targetTime: TimeInterval
    public let notify: Bool

    init(id: HabitID?, title: String, goalSpan: GoalSpan, targetTime: TimeInterval, notify: Bool) {
        self.id = id
        self.title = title
        self.goalSpan = goalSpan
        self.targetTime = targetTime
        self.notify = notify
    }

    init(createNewHabitWithTitle title: String, goalSpan: GoalSpan, targetTime: TimeInterval, notify: Bool) {
        self.init(id: nil, title: title, goalSpan: goalSpan, targetTime: targetTime, notify: notify)
    }

    var readableString: String {
        let time = Habit.timeFormatter.string(from: targetTime) ?? ""
        return "\(goalSpan.localizedString)に\(time)時間 \"\(title)\" をする"
    }

    static let timeFormatter: DateComponentsFormatter = {
        let fmt = DateComponentsFormatter()
        fmt.allowedUnits = [.hour]
        return fmt
    }()

    public func hash(into hasher: inout Hasher) {
        if let id = id {
            hasher.combine(id)
        }
    }
}
