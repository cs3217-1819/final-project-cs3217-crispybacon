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

    /// Prompts user for input. Comes with 2 action buttons: "OK" and "Cancel".
    /// - Parameters:
    ///     - title: Title of the alert.
    ///     - message: Message (body) of the alert.
    ///     - style: Alert style, defaults to `UIAlertController.Style.alert`.
    ///     - inputPlaceholder: Input placeholder text, defaults to an empty string.
    ///     - inputValidator: Used to validate user input, defaults to a check for an empty string.
    ///     - successHandler: Will be called with user's input if `inputValidator(userInput) == true`.
    ///     - failureHandler: Will be called with user's input if `inputValidator(userInput) == false`.
    ///       Defaults to do nothing.
    func promptUserForInput(title: String,
                            message: String,
                            style: UIAlertController.Style = .alert,
                            inputPlaceholder: String = "",
                            inputValidator: @escaping (String) -> Bool = { $0 != "" },
                            successHandler: @escaping (String) -> Void,
                            failureHandler: @escaping (String) -> Void = { _ in return }) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: style)
        alert.addTextField { $0.placeholder = inputPlaceholder }
        alert.addAction(UIAlertAction(title: "OK", style: .default) {_ in
            guard let userInput = alert.textFields?.first?.text else {
                fatalError("This should never happen")
            }

            if !inputValidator(userInput) {
                failureHandler(userInput)
                return
            }

            successHandler(userInput)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }

    /// Handles error and presents message to the user.
    /// - Parameters:
    ///     - error: The error to be handled.
    ///     - customMessage: Message to be presented to the user, if the error is not among the defined ones.
    func handleError(error: Error, customMessage: String) {
        if let initError = error as? InitializationError {
            self.alertUser(title: Constants.warningTitle, message: initError.message)
        }
        if let storageError = error as? StorageError {
            self.alertUser(title: Constants.warningTitle, message: storageError.message)
        }
        if let argError = error as? InvalidArgumentError {
            self.alertUser(title: Constants.warningTitle, message: argError.message)
        }
        if let duplicateTagError = error as? DuplicateTagError {
            self.alertUser(title: Constants.warningTitle, message: duplicateTagError.message)
        }
        if let invalidTagError = error as? InvalidTagError {
            self.alertUser(title: Constants.warningTitle, message: invalidTagError.message)
        } else {
            self.alertUser(title: Constants.warningTitle, message: customMessage)
        }
    }
}
