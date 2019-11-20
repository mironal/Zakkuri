//
//  SettingViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/20.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class SettingViewModel {
    struct Inputs {
        let tapReminderTimeCell: Observable<Void>
        let tapGetHowToCell: Observable<Void>
        let tapDone: Observable<Void>
    }

    struct Outputs {
        let showHowTo: Signal<PreviewVideoPlayerViewModel>
        let dismiss: Signal<Void>
    }

    func bind(_ inputs: Inputs) -> Outputs {
        return .init(
            showHowTo: inputs.tapGetHowToCell.map { PreviewVideoPlayerViewModel() }.asSignal(onErrorSignalWith: .never()),
            dismiss: inputs.tapDone.asSignal(onErrorSignalWith: .never())
        )
    }
}
