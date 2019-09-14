//
//  SummaryCell.swift
//  laid-back
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

public struct SummaryCellState {
    let habit: Habit
}

public class SummaryCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var progressBase: UIView!
    @IBOutlet var progressBar: UIView!

    var state: SummaryCellState! {
        didSet {
            titleLabel.text = state.habit.title
            descriptionLabel.text = state.habit.readableString
        }
    }
}
