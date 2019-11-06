//
//  UserModel.swift
//  Zakkuri
//
//  Created by mironal on 2019/11/06.
//  Copyright © 2019 mironal. All rights reserved.
//

import Firebase
import FirebaseAuth
import Foundation
import RxSwift

import XCGLogger

extension Reactive where Base: Auth {
    var currentUser: Observable<User> {
        let auth = base
        return Observable.create { observable -> Disposable in
            let handle = auth.addStateDidChangeListener { auth, user in
                guard let user = user else {
                    auth.signInAnonymously { _, error in
                        if let error = error {
                            observable.onError(error)
                            return
                        }
                    }
                    return
                }
                observable.onNext(user)
            }
            return Disposables.create {
                auth.removeStateDidChangeListener(handle)
            }
        }
    }
}
