//
//  HabitRecord.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/12.
//  Copyright © 2019 mironal. All rights reserved.
//

import FirebaseFirestoreSwift
import Foundation

public typealias HabitRecordID = String

public struct HabitRecord: Codable {
    @DocumentID public var id: HabitRecordID?
    public let habitId: HabitID
    public let duration: TimeInterval
    @ServerTimestamp public var createdAt: Date?

    // イニシャライザがないと segmentation fault:11 になる...
    init(id: HabitRecordID? = nil, habitId: HabitID, duration: TimeInterval, createdAt: Date? = nil) {
        self.id = id
        self.habitId = habitId
        self.duration = duration
        self.createdAt = createdAt
    }
}
