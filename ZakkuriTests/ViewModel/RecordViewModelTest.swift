//
//  RecordViewModelTest.swift
//  ZakkuriTests
//
//  Created by mironal on 2019/09/25.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxSwift
import RxTest
import XCTest
@testable import Zakkuri

class RecordViewModelTest: XCTestCase {
    var service: Models!

    override func setUp() {
        let storage = InMemoryStorage()

        storage.habits.append(.init(id: "1", title: "hoge", goalSpan: .aWeek, targetTime: 100_000))

        let habitModel = HabitModel(storage: storage)

        service = Models(habit: habitModel)
    }

    override func tearDown() {}

    func test() {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let tapDone: Observable<TimeInterval> = scheduler.createHotObservable([.init(time: 100, value: .next(1.0))]).asObservable()
        let tapNext: Observable<Void> = scheduler.createHotObservable([]).asObservable()

        let viewModel = RecordViewModel(habitId: "1", service: service)
        let inputs = RecordViewModel.Inputs(tapDone: tapDone, tapNext: tapNext)
        let outputs = viewModel.bind(inputs)

        let expectedTitle = scheduler.createObserver(String.self)
        let expectedShowDetail = scheduler.createObserver(HabitDetailViewModel.self)
        let expectedDismiss = scheduler.createObserver(Void.self)

        outputs.title.bind(to: expectedTitle).disposed(by: disposeBag)
        outputs.showDetail.bind(to: expectedShowDetail).disposed(by: disposeBag)
        outputs.dismiss.bind(to: expectedDismiss).disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(expectedTitle.events, [
            .next(0, "hoge"),
        ])

        XCTAssertTrue(expectedShowDetail.events.isEmpty)

        XCTAssertEqual(expectedDismiss.events.first!.time, 100)
    }
}
