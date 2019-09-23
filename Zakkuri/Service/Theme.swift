//
//  Theme.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/23.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

class ThemeAppier {
    let baseColor = UIColor(hexString: "5289FF")
    let secondColor = UIColor(hexString: "2753B3")
    let accentColor = UIColor(hexString: "FF836B")

    func apply() {
//        UIButton.appearance().tintColor = baseColor
        UISlider.appearance().tintColor = baseColor

        UINavigationBar.appearance().barTintColor = baseColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white
    }
}
