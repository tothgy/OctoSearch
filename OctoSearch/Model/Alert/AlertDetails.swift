//
//  AlertDetails.swift
//  OctoSearch
//

import UIKit

struct AlertAction {

    var title: String? {
        return wrappedAction.title
    }
    var style: UIAlertAction.Style
    var handler: ((UIAlertAction) -> Void)?
    var nativeAction: UIAlertAction {
        return wrappedAction
    }
    private var wrappedAction: UIAlertAction

    init(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.handler = handler
        self.style = style
        self.wrappedAction = UIAlertAction(title: title, style: style, handler: handler)
    }

    static let okAction = AlertAction(title: L10n.Alert.Action.ok, style: .default)
}

struct AlertDetails: Equatable {
    static func == (lhs: AlertDetails, rhs: AlertDetails) -> Bool {
        guard lhs.actions.count == rhs.actions.count else { return false}

        var actionsAreEqual = true
        for i in 0...lhs.actions.count - 1 {
            let action1 = lhs.actions[i]
            let action2 = rhs.actions[i]
            actionsAreEqual = actionsAreEqual && action1.title == action2.title && action1.style == action2.style
        }

        return
            lhs.title == rhs.title &&
            lhs.message == rhs.message &&
            actionsAreEqual
    }

    var title: String
    var message: String
    var error: Error?
    var actions: [AlertAction]
}
