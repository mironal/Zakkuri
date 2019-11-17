//
//  SummaryCell.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/14.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxDataSources
import UIKit

public protocol SummaryCellState {
    var title: String { get }
    var spentTimeInDuration: TimeInterval { get }
    var goalSpan: GoalSpan { get }
    var progress: Float { get }
}

struct SectionOfSummaryCellState: SectionModelType {
    var items: [SummaryCellState]
    typealias Item = SummaryCellState

    init(items: [SummaryCellState]) {
        self.items = items
    }

    init(original: SectionOfSummaryCellState, items: [SummaryCellState]) {
        self = original
        self.items = items
    }
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
