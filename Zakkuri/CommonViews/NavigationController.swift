//
//  NavigationController.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/23.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
}
