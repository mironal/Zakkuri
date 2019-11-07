//
//  FirestoreStorage.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/06.
//  Copyright © 2019 mironal. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import RxSwift
import XCGLogger

public enum FirestoreStorageError: Error, LocalizedError {
    case invalidOperation
}

func observeUser(_ auth: Auth) -> Observable<User> {
    return .create { o -> Disposable in
        XCGLogger.default.debug("addStateDidChangeListener")
        let handle = auth.addStateDidChangeListener { auth, user in

            if let user = user {
                XCGLogger.default.debug("onNext:\(user)")
                o.onNext(user)
                return
            }

            auth.signInAnonymously { _, error in
                if let error = error {
                    XCGLogger.default.error(error)
                    o.onError(error)
                }
            }
        }

        return Disposables.create {
            auth.removeStateDidChangeListener(handle)
            XCGLogger.default.debug("removeStateDidChangeListener")
        }
    }
}

extension Firestore {
    var usersCollection: CollectionReference {
        return collection("users")
    }

    func habitsCollection(_ uid: String) -> CollectionReference {
        return usersCollection.document(uid).collection("habits")
    }

    func recordsCollection(_ uid: String) -> CollectionReference {
        return usersCollection.document(uid).collection("records")
    }
}

private func observeHabits(_ uid: String, firestore: Firestore) -> Observable<[Habit]> {
    return .create { o in
        XCGLogger.default.debug("Create observeHabits")
        let hanble = firestore.habitsCollection(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                o.onError(error)
                return
            }

            guard let documents = snapshot?.documents else { return }

            do {
                let habits = try documents.compactMap {
                    try $0.data(as: Habit.self)
                }
                o.onNext(habits)
            } catch let e { o.onError(e) }
        }
        return Disposables.create { hanble.remove() }
    }
}

private func observeHabitRecords(_ uid: String, firestore: Firestore) -> Observable<[HabitRecord]> {
    return .create { o in
        let handle = firestore.recordsCollection(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                o.onError(error)
                return
            }

            guard let documents = snapshot?.documents else { return }

            do {
                let records = try documents.compactMap {
                    try $0.data(as: HabitRecord.self)
                }
                o.onNext(records)
            } catch let e { o.onError(e) }
        }
        return Disposables.create { handle.remove() }
    }
}

private func addHabit(_ habit: Habit, user uid: String, firestore: Firestore) -> Single<Void> {
    if habit.id != nil {
        return .error(FirestoreStorageError.invalidOperation)
    }
    return .create { single in
        do {
            _ = try firestore.habitsCollection(uid).addDocument(from: habit) { error in
                if let error = error { single(.error(error)) }
                else { single(.success(())) }
            }
        } catch let e { single(.error(e)) }
        return Disposables.create {}
    }
}

private func updateHabit(_ habit: Habit, user uid: String, firestore: Firestore) -> Single<Void> {
    guard let habitId = habit.id else {
        return .error(FirestoreStorageError.invalidOperation)
    }
    return .create { single in
        do {
            try firestore.habitsCollection(uid).document(habitId).setData(from: habit) { error in
                if let error = error { single(.error(error)) }
                else { single(.success(())) }
            }
        } catch let e { single(.error(e)) }
        return Disposables.create {}
    }
}

private func addOrUpdateHabit(_ habit: Habit, user uid: String, firestore: Firestore) -> Single<Void> {
    if habit.id == nil {
        return addHabit(habit, user: uid, firestore: firestore)
    }
    return updateHabit(habit, user: uid, firestore: firestore)
}

private func addHabitRecord(_ record: HabitRecord, user uid: String, firestore: Firestore) -> Single<Void> {
    return .create { single in
        do {
            _ = try firestore.recordsCollection(uid).addDocument(from: record) { error in
                if let error = error { single(.error(error)) }
                else { single(.success(())) }
            }
        } catch let e { single(.error(e)) }
        return Disposables.create {}
    }
}

private func deleteHabit(_ habitId: HabitID, user uid: String, firestore: Firestore) -> Single<HabitID> {
    return .create { single in

        // habit に紐づく habit record を消すのはクライアントサイドでは非効率なので functions で削除する
        firestore.habitsCollection(uid).document(habitId).delete {
            if let error = $0 {
                single(.error(error))
                return
            }
            single(.success(habitId))
        }
        return Disposables.create {}
    }
}

private func deleteHabitRecord(_ recordId: String, user uid: String, firestore: Firestore) -> Single<String> {
    return .create { single in
        firestore.recordsCollection(uid).document(recordId).delete {
            if let error = $0 {
                single(.error(error))
                return
            }
            single(.success(recordId))
        }
        return Disposables.create {}
    }
}

/*

 - /users/{uid}
    - /habits/{habitId}/habit document
    - /records/{recordId}/habit record
 */

public class FirestoreStorage: StorageProtocol {
    private let auth: Auth
    private let firestore: Firestore
    private let disposeBag = DisposeBag()

    init(auth: Auth, firestore: Firestore) {
        self.auth = auth
        self.firestore = firestore
    }

    private lazy var currentUser: Observable<User> = observeUser(self.auth).share(replay: 1)

    public private(set) lazy var habits: Observable<[Habit]> = {
        let firestore = self.firestore
        return self.currentUser.flatMapLatest {
            observeHabits($0.uid, firestore: firestore)
        }.share(replay: 1)
    }()

    public var habitRecords: Observable<[HabitRecord]> {
        let firestore = self.firestore
        return currentUser.flatMapLatest {
            observeHabitRecords($0.uid, firestore: firestore)
        }.share(replay: 1)
    }

    public func add(_ habit: Habit) {
        let firestore = self.firestore
        currentUser.flatMapLatest {
            addOrUpdateHabit(habit, user: $0.uid, firestore: firestore)
        }.subscribe().disposed(by: disposeBag)
    }

    public func add(_ record: HabitRecord) {
        let firestore = self.firestore
        return currentUser.flatMapLatest {
            addHabitRecord(record, user: $0.uid, firestore: firestore)
        }.subscribe().disposed(by: disposeBag)
    }

    public func deleteHabitAndRecords(_ habitId: HabitID) {
        let firestore = self.firestore
        return currentUser.flatMapLatest {
            deleteHabit(habitId, user: $0.uid, firestore: firestore)
        }.subscribe().disposed(by: disposeBag)
    }

    public func deleteRecord(_ recordId: String) {
        let firestore = self.firestore
        return currentUser.flatMapLatest {
            deleteHabitRecord(recordId, user: $0.uid, firestore: firestore)
        }.subscribe().disposed(by: disposeBag)
    }
}
