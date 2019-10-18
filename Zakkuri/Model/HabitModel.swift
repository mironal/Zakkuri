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
protocol HabitModelProtocol {
    // モデルの変化
    var habits: Observable<[Habit]> { get }
    // var habitsError: Observable<Error> { get }

    var habitAddResult: Observable<Void> { get }

    // モデルに変化を与えるメソッド群
    func add(_ habit: Habit)
    func remove(_ habitId: HabitID)
}

/*
 void な function の理由
 1. add はなにかの modal view でやって add したら閉じるみたいなパターンで発生するバグが記述しにくくなる
 2. 変化を与える場所と、変化を受け取る場所がどこにあっても大丈夫 -> 仕様変更に強い

 */
class HabitModel: HabitModelProtocol {
    // Subject は subscribe できるし onNext もできる
    private let habitsErrorSubject = PublishSubject<Error>()

    // Observable は subscribe できる.
    var habitsError: Observable<Error> {
        // PublishSubject は Subject + Observable だがモデルの外部からは Observable
        // であってほしいので Observable に cast して返す.
        return habitsErrorSubject
    }

    private let habitsSubject = PublishSubject<[Habit]>()
    var habits: Observable<[Habit]> {
        return habitsSubject
    }

    let disposeBag = DisposeBag()

    private let habitAddResultSubject = PublishSubject<Void>()
    var habitAddResult: Observable<Void> {
        return habitAddResultSubject
    }

    func add(_: Habit) {
        // add の戻り値が void な理由は安全に add の処理を完了させる為です.
        // void ではなく仮に Single<()> だとしたら
        // 以下のようなコードが model 内に書けてしまうので
        // これを呼び出す側が即座に開放されるとリクエストが cancel されてしまい
        // 予期せぬ動作を引き起こす可能が生まれてしまいます.
        // void にすれば model 内で dispose の処理を書くようになるため model が
        // 開放されるまで dispose されないので安全です.
//        return .create { single in
//
//            // API 叩く
//            // var cancel = API
//
//            return Disposables.create {
//                // cancel()
//            }

        habitAddResultSubject.onNext(()) // 成功通知
    }

    func remove(_: HabitID) {}
}
