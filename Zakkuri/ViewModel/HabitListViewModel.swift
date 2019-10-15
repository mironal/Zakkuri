//
//  HabitListViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/15.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation

// どういう ViewModel にするかは話し合ってから決める. 結構大変.

protocol HabitListViewModelService {
    var habitModel: HabitModelProtocl { get }
}

class HabitListViewModel {

    public struct Inputs {

    }
    public struct Outputs {

    }

    let habitModel: HabitModelProtocl
    init(_ service: HabitListViewModelService) {
        habitModel = service.habitModel
    }

    func bind( _ inputs: Inputs) -> Outputs {
        habitModel.habits
        return .init()
    }
}
