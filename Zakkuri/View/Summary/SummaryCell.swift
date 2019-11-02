//
//  SummaryCell.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import UIKit

public protocol SummaryCellState {
    var title: String { get }
    var spentTimeInDuration: TimeInterval { get }
    var goalSpan: GoalSpan { get }
    var progress: Float { get }
}

public class SummaryCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    @IBOutlet var progressView: UIProgressView!

    var state: SummaryCellState! {
        didSet {
            titleLabel.text = state.title

            let fmt = Formatters.spentTime
            let summary = "You spent \(fmt.string(from: state.spentTimeInDuration) ?? "0") in the last \(state.goalSpan.localizedString)"

            descriptionLabel.text = summary
            progressView.progress = state.progress
        }
    }
}
