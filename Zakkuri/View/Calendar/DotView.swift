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

    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        updateDot(shapeLayer)
        shapeLayer.fillColor = dotColor.cgColor
        layer.addSublayer(shapeLayer)
        return shapeLayer
    }()

    private func updateDot(_ shapeLayer: CAShapeLayer) {
        shapeLayer.path = UIBezierPath(ovalOf: .init(width: dotSize, height: dotSize), centered: true).cgPath
        shapeLayer.position = .init(x: layer.bounds.midX, y: layer.bounds.midY)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateDot(shapeLayer)
    }
}
