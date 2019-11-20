//
//  Theme.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/23.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

public struct Theme {
    let baseColor: UIColor
    let secondColor: UIColor
    let accentColor: UIColor

    public static let defailt = Theme(baseColor: UIColor(named: "baseColor")!,
                                      secondColor: UIColor(named: "secondColor")!,
                                      accentColor: UIColor(named: "accentColor")!)
}

class ThemeAppier {
    let theme: Theme = Theme.defailt

    func apply() {
        UISlider.appearance().tintColor = theme.baseColor

        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().barTintColor = theme.baseColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white

        UITabBar.appearance().tintColor = theme.baseColor
    }
}
