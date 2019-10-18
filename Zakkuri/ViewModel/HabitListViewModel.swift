//
//  HabitListViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/15.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxSwift

// どういう ViewModel にするかは話し合ってから決める. 結構大変.

protocol HabitListViewModelService {
    var habitModel: HabitModelProtocol { get }
}

extension Models: HabitListViewModelService {}

class HabitListViewModel {
    public struct Inputs {
        let tapAdd: Observable<Void>
    }

    public struct Outputs {
        let success: Observable<Void>
        let showInput: Observable<HabitInputViewModel>
    }

    let habitModel: HabitModelProtocol
    init(_ service: HabitListViewModelService = Models.shared) {
        habitModel = service.habitModel
    }

    func bind(_ inputs: Inputs) -> Outputs {
        return .init(
            success: habitModel.habitAddResult,
            showInput: inputs.tapAdd.map { _ in HabitInputViewModel() }
        )
    }
}
