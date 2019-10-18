//
//  HabitInputViewModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/18.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxSwift

protocol HabitInputViewModelService {
    var habitModel: HabitModelProtocol { get }
}

extension Models: HabitInputViewModelService {}

class HabitInputViewModel {
    public struct Inputs {
        let tapCancel: Observable<Void>
        let tapAdd: Observable<Void>
        let changeText: Observable<String>
    }

    public struct Outputs {
        let dismiss: Observable<Void>
    }

    private let disposeBag = DisposeBag()
    let habitModel: HabitModelProtocol
    init(_ service: HabitInputViewModelService = Models.shared) {
        habitModel = service.habitModel
    }

    func bind(_ inputs: Inputs) -> Outputs {
        let habitModel = self.habitModel

        inputs.tapAdd.withLatestFrom(inputs.changeText)
            .subscribe(onNext: {
                habitModel.add(.init(id: UUID().uuidString, title: $0))
            }).disposed(by: disposeBag)

        return .init(
            dismiss: .merge(inputs.tapCancel, inputs.tapAdd)
        )
    }
}
