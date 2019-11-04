//
//  CalendarDayCell.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import JTAppleCalendar
import RxCocoa
import RxSwift
import UIKit

class CalendarDayCell: JTACDayCell {
    struct State {
        let day: String
        let numOfDots: Int
        let thisMonth: Bool
    }

    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dotStackView: UIStackView!

    public var state: State = .init(day: "1", numOfDots: 0, thisMonth: false) {
        didSet {
            dayLabel.text = state.day
            dotStackView.removeArrangedSubviews()
            Array(repeating: (), count: state.numOfDots).forEach {
                let view = DotView(frame: .zero)
                dotStackView.addArrangedSubview(view)
            }

            dayLabel.textColor = state.thisMonth ? .black : .gray
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.addBorder(edge: .bottom, color: .gray, thickness: 1)
    }
}
