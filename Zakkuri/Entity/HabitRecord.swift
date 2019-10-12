//
//  HabitRecord.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

public struct HabitRecord: Codable {
    public let habitId: HabitID
    public let duration: TimeInterval
    public let createdAt: Date

    public var recordId: String {
        return "\(habitId)_\(createdAt.unixTimestamp)"
    }
}
