//
//  CalendarDayCell.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/04.
//  Copyright © 2019 mironal. All rights reserved.
//

import JTAppleCalendar
import UIKit

class CalendarDayCell: JTACDayCell {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dotStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.addBorder(edge: .bottom, color: .gray, thickness: 1)

        let dotView = DotView(frame: .zero)
        dotStackView.addArrangedSubview(dotView)
    }
}
