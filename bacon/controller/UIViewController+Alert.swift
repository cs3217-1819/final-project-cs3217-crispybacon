//
//  UIViewController+Alert.swift
//  bacon
//
//  Created by Lizhi Zhang on 3/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Alerts user. Comes with a single action button: "OK".
    /// - Parameters:
    ///     - title: Title of the alert.
    ///     - message: Message (body) of the alert.
    ///     - style: Alert style, defaults to `UIAlertController.Style.alert`.
    func alertUser(title: String,
                   message: String,
                   style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: style)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }

    /// Handles error and presents message to the user.
    /// - Parameters:
    ///     - error: The error to be handled.
    ///     - customMessage: Message to be presented to the user, if the error is not among the defined one.
    func handleError(error: Error, customMessage: String) {
        if let initError = error as? InitializationError {
            self.alertUser(title: Constants.warningTitle, message: initError.message)
        }
        if let argError = error as? InvalidArgumentError {
            self.alertUser(title: Constants.warningTitle, message: argError.message)
        } else {
            self.alertUser(title: Constants.warningTitle, message: customMessage)
        }
    }
}
