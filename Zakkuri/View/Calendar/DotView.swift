//
//  DotView.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

@IBDesignable
class DotView: UIView {
    @IBInspectable var dotColor: UIColor = .black {
        didSet {
            shapeLayer.fillColor = dotColor.cgColor
        }
    }

    @IBInspectable var dotSize: CGFloat = 4 {
        didSet {
            updateDot(shapeLayer)
        }
    }

    convenience init(dotSize: CGFloat = 4, dotColor: UIColor = .black) {
        self.init(frame: .zero)
        self.dotSize = dotSize
        self.dotColor = dotColor
    }

    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        updateDot(shapeLayer)
        shapeLayer.fillColor = dotColor.cgColor
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }()

    private func updateDot(_ shapeLayer: CAShapeLayer) {
        shapeLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        shapeLayer.path = UIBezierPath(arcCenter: .init(x: bounds.midX, y: bounds.midY),
                                       radius: dotSize / 2,
                                       startAngle: 0,
                                       endAngle: CGFloat.pi * 2,
                                       clockwise: true).cgPath
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateDot(shapeLayer)
    }
}
