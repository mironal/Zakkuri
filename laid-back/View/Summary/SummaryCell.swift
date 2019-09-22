//
//  SummaryCell.swift
//  laid-back
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

public struct SummaryCellState {
    let summary: HabitSummary
}

public class SummaryCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var progressView: UIProgressView!

    var state: SummaryCellState! {
        didSet {
            titleLabel.text = state.summary.habit.title
            descriptionLabel.text = state.summary.habit.readableString
            progressView.progress = Float(state.summary.spentTimeInDuration / state.summary.habit.targetTime)
        }
    }
}
