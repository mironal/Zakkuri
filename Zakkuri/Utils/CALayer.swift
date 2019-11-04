//
//  CALayer.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = CALayer()

        switch edge {
        case .top:
            border.frame = .init(x: 0, y: 0, width: frame.height, height: thickness)
        case .bottom:
            border.frame = .init(x: 0, y: frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
        case .left:
            border.frame = .init(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = .init(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }

        border.backgroundColor = color.cgColor

        addSublayer(border)
    }
}
