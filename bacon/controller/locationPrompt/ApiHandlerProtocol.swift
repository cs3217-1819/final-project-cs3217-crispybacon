//
//  ApiHandlerProtocol.swift
//  bacon
//
//  Created by Fabian Terh on 18/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import Foundation

/// API handlers send requests to and interpret responses from
/// specific remote resources to determine if a user should
/// receive a prompt based on the current location.
protocol ApiHandler {

    /// Sends a request to this ApiHandler's API endpoint,
    /// interprets the response (or handles a failure),
    /// and calls `decisionHandler` with the decision
    /// (`true` to prompt and `false` otherwise).
    func sendRequest(currentLocation: CLLocation,
                     decisionHandler: @escaping (Bool) -> Void)

}
