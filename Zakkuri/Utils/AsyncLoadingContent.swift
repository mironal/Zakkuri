//
//  AsyncLoadingContent.swift
//  Zakkuri
//
//  Created by mironal on 2019/12/08.
//  Copyright © 2019 mironal. All rights reserved.
//

import Foundation
import RxSwift

protocol AsyncLoadingContentType {
    associatedtype ElementType
    var loading: Bool { get }
    var content: ElementType? { get }
    var error: Error? { get }
}

enum AsyncLoadingContent<ElementType>: AsyncLoadingContentType {
    case loading
    case content(ElementType)
    case error(Error)

    var loading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var content: ElementType? {
        if case let .content(content) = self { return content }
        return nil
    }

    var error: Error? {
        if case let .error(e) = self { return e }
        return nil
    }
}

extension ObservableType {
    /**
     Add loading status until first next.

         let loadingContnt = someAsyncLoadingObservable().loadingContent()

         loadingContnt.loading.subscribe( /* some thing*/ );
         loadingContnt.content.subscribe( /* some thing*/ );
         loadingContnt.error.subscribe( /* some thing*/ );
     */
    func loadingContent() -> Observable<AsyncLoadingContent<Element>> {
        materialize().compactMap {
            switch $0 {
            case let .error(error):
                return AsyncLoadingContent.error(error)
            case let .next(elem):
                return AsyncLoadingContent.content(elem)
            case .completed:
                return nil
            }
        }.startWith(AsyncLoadingContent.loading)
    }
}

extension Observable where Element: AsyncLoadingContentType {
    var loading: Observable<Bool> {
        map { $0.loading }
    }

    var content: Observable<Element.ElementType> {
        compactMap { $0.content }
    }

    var error: Observable<Error> {
        compactMap { $0.error }
    }
}
