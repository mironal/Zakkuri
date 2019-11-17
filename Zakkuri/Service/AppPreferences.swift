//
//  AppPreferences.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/17.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

private let AppPreferencesKeyLastLaunchVersion = "zakkuri.AppPreferencesKeyLastLaunchVersion"

public final class AppPreferences {
    public static let shared: AppPreferences = AppPreferences()
    private init() {}

    private let userDefaults = UserDefaults.standard

    public var lastLaunchVersion: String? {
        set {
            userDefaults.set(newValue, forKey: AppPreferencesKeyLastLaunchVersion)
        }
        get {
            userDefaults.string(forKey: AppPreferencesKeyLastLaunchVersion)
        }
    }
}
