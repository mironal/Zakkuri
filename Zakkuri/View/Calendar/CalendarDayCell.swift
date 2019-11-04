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

            dayLabel.textColor = state.thisMonth ? .black : .gray
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.addBorder(edge: .bottom, color: .gray, thickness: 1)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        state = .init(day: "1", numOfDots: 0, thisMonth: false)
    }
}
