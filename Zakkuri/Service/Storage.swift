//
//  Storage.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import SwifterSwift

public protocol StorageProtocol {
    var habits: Observable<[Habit]> { get }
    var habitRecords: Observable<[HabitRecord]> { get }

    func addOrUpdate(_ habit: Habit)
    func updates(_ habits: [Habit])
    func add(_ record: HabitRecord)

    func deleteHabitAndRecords(_ habitId: HabitID)
    func deleteRecord(_ recordId: String)
}
