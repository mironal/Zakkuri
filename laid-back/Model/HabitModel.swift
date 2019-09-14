//
//  HabitModel.swift
//  laid-back
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift

public enum GoalSpan: Int, CaseIterable, Codable {
    case aDay, aWeek, aMonth
    var localizedString: String {
        switch self {
        case .aDay: return "1日"
        case .aWeek: return "1週間"
        case .aMonth: return "1ヶ月"
        }
    }
}

public struct Habit: Codable {
    let title: String
    let goalSpan: GoalSpan
    let targetTime: TimeInterval

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

public protocol HabitModelProtocol {
    var habits: Observable<[Habit]> { get }

    func add(_ habit: Habit)
}

public class HabitModel: HabitModelProtocol {
    private let habitsRelay = BehaviorRelay<[Habit]>(value: [])
    public var habits: Observable<[Habit]> {
        return habitsRelay.asObservable()
    }

    public func add(_ habit: Habit) {
        var value = habitsRelay.value
        value.append(habit)
        habitsRelay.accept(value)
    }
}
