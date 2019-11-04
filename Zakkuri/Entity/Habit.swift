//
//  Habit.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

public typealias HabitID = String

public struct Habit: Codable, Equatable, Hashable {
    public let id: HabitID
    public let title: String
    public let goalSpan: GoalSpan
    public let targetTime: TimeInterval
    public let notify: Bool

    private enum Keys: CodingKey {
        case id, title, goalSpan, targetTime, notify
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        goalSpan = try c.decode(GoalSpan.self, forKey: .goalSpan)
        targetTime = try c.decode(TimeInterval.self, forKey: .targetTime)
        notify = (try? c.decode(Bool.self, forKey: .notify)) ?? false
    }

    init(id: HabitID, title: String, goalSpan: GoalSpan, targetTime: TimeInterval, notify: Bool) {
        self.id = id
        self.title = title
        self.goalSpan = goalSpan
        self.targetTime = targetTime
        self.notify = notify
    }

    init(createNewHabitWithTitle title: String, goalSpan: GoalSpan, targetTime: TimeInterval, notify: Bool) {
        self.init(id: UUID().uuidString, title: title, goalSpan: goalSpan, targetTime: targetTime, notify: notify)
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
}
