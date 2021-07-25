//
//  TestHelpers.swift
//  InstructorTests
//

import Foundation
import SwinjectStoryboard
import Swinject
import RxSwift
import Nimble
import Moya

enum TestHelpersError: Error {
    case cannotInstantiateViewController
}

internal func instantiateViewController<T: UIViewController>(ofType type: T.Type,
                                                             withIdentifier identifier: String,
                                                             fromStoryboardNamed storyboardName: String = "Main",
                                                             container: Container = SwinjectStoryboard.defaultContainer) throws -> T {
    let storyboard = SwinjectStoryboard.create(name: storyboardName, bundle: nil, container: container)
    if let controller = storyboard.instantiateViewController(withIdentifier: identifier) as? T {
        return controller
    } else {
        throw TestHelpersError.cannotInstantiateViewController
    }
    
}

internal func subscribe<T>(to observable: Observable<T>, trigger: (() -> Void)? = nil, verify: ([T]) -> Void) -> Disposable {
    var updates: [T] = []
    let disposable = observable
        .subscribe(onNext: { (value: T) in
            updates.append(value)
        })
    // when
    if let trigger = trigger {
        trigger()
    }
    // then
    verify(updates)
    return disposable
}

internal func subscribe<T>(to observable: Observable<T>, trigger: (() -> Void)? = nil, errors: ([Error]) -> Void) -> Disposable {
    var emittedErrors: [Error] = []
    let disposable = observable
        .subscribe(onError: { (error: Error) in
            emittedErrors.append(error)
        })
    // when
    if let trigger = trigger {
        trigger()
    }
    // then
    errors(emittedErrors)
    return disposable
}

internal func presentAsInitialViewController(_ viewController: UIViewController) {
    let window = UIWindow()
    window.rootViewController = viewController
    window.makeKeyAndVisible()
}

func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

func executeRunLoop(_ interval: TimeInterval = 0) {
    RunLoop.current.run(until: Date(timeInterval: interval, since: Date()))
}

extension UITextField {
    func sendEditingChanged(withText value: String) {
        text = value
        sendActions(for: .editingChanged)
    }
}
