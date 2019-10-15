//
//  HabitModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/10/15.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxSwift

typealias HabitID = String

struct Habit {
    let id: HabitID
    let title: String
}

// Model とはこうあるべきだ論:
// モデルの外側(ViewModle)から見たときに(原則として)
// モデルに変化(add Habit するとか)を与える方法: void なメソッドによって外部からトリガする
// モデルの変化を受け取る(habit 一覧を取得)方法: Observable な property によって外部から観測する.
//
protocol HabitModelProtocl {

    // モデルの変化
    var habits: Observable<[Habit]> { get }
    var habitsError: Observable<Error> { get }

    // モデルに変化を与えるメソッド群
    func add(_ habit: Habit) // API アクセスで2秒ぐらいいかかる
    func remove(_ habitId: HabitID)
}

/*
 void な function の理由
 1. add はなにかの modal view でやって add したら閉じるみたいなパターンで発生するバグが記述しにくくなる
 2. 変化を与える場所と、変化を受け取る場所がどこにあっても大丈夫 -> 仕様変更に強い

 */
class HabitModel: HabitModelProtocl {

    let habitsSubject = firebse.database.rx.habits

    var habits: Observable<[Habit]> {
        return habitsSubject
    }

    let disposeBag = DisposeBag()

    func add(_ habit: Habit) {
        API.rx.create.request(habit)
            .subscribe(onError: habitsErrorSubject.accept)
            .disposed(by: disposeBag)
    }

    func remove(_ habitId: HabitID) {
    }



}

