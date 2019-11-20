//
//  UIViewController.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/11.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

extension UIViewController {
    private static func loadFromStoryboard<T>(withClass name: T.Type) -> T? where T: UIViewController {
        let sb = UIStoryboard(name: String(describing: name), bundle: .main)
        return sb.instantiateInitialViewController()
    }

    static func instantiateFromStoryboard() -> Self? {
        return loadFromStoryboard(withClass: self)
    }
}
