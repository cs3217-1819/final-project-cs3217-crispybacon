//
//  LocationPrompt.swift
//  bacon
//
//  Created by Fabian Terh on 18/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import Foundation
import Alamofire
import SwiftyJSON

class LocationPrompt {

    private static let apiHandler: ApiHandler = GooglePlacesApiHandler()

    /// Decides if the user should receive a prompt to record a transaction.
    /// - Parameters:
    ///     - currentLocation: The user's current location.
    ///     - callback: This will be fired after LocationPrompt makes a decision.
    ///         It will be called with `true` if the user should be prompted, and `false` otherwise.
    static func shouldPromptUser(currentLocation: CLLocation,
                                 decisionHandler: @escaping (Bool) -> Void) {
        apiHandler.sendRequest(currentLocation: currentLocation, decisionHandler: decisionHandler)
    }

}
