//
//  AlertController.swift
//  Zakkuri
//
//  Created by mironal on 2019/09/23.
//  Copyright © 2019 mironal. All rights reserved.
//

import RxSwift
import UIKit

extension UIAlertController {
    public enum ConfirmDeleteActionResult {
        case delete, cancel
    }

    public static func confirmDelete(_ title: String? = "Are you sure?", message: String? = nil) -> (_ present: UIViewController) -> Observable<ConfirmDeleteActionResult> {
        return { vc in

            Observable.create { observer in

                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(title: "Cancel", style: .cancel, isEnabled: true, handler: { _ in
                    observer.onNext(.cancel)
                })

                alert.addAction(title: "Delete", style: .destructive, isEnabled: true, handler: { _ in
                    observer.onNext(.delete)
                })

                vc.present(alert, animated: true)

                return Disposables.create {
                    alert.dismiss(animated: false)
                }
            }
        }
    }
}
