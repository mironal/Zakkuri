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
        let selected: Bool

        static let empty: State = .init(day: "1", numOfDots: 0, thisMonth: false, selected: false)
    }

    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dotStackView: UIStackView!
    @IBOutlet var selectedView: UIView!

    public var state: State = .empty {
        didSet {
            dayLabel.text = state.day
            dayLabel.textColor = state.thisMonth ? .black : .gray

            selectedView.isHidden = !state.selected
            borderWidth = state.selected ? 1 : 0

            if state.selected {
                cornerRadius = 6
                borderColor = .lightGray
                dayLabel.textColor = .white
                selectedView.cornerRadius = selectedView.height / 2
            }

            // removeFromSuperview も呼ばないと view が消えない...
            dotStackView.arrangedSubviews.forEach {
                $0.removeFromSuperview()
            }
            dotStackView.removeArrangedSubviews()

            let views = Array(repeating: (), count: state.numOfDots).map {
                DotView(frame: .zero)
            }

            dotStackView.addArrangedSubviews(views)
            // 2個の場合は間延びするので両側に空の View を入れて dot を中央に寄せる
            if state.numOfDots == 2 {
                dotStackView.insertArrangedSubview(UIView(frame: .zero), at: 0)
                dotStackView.addArrangedSubview(UIView(frame: .zero))
            }
            setNeedsDisplay()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        state = .empty
    }
}
