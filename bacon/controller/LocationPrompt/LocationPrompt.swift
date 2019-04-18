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

    // See: https://developers.google.com/places/web-service/search for documentation
    private static let apiBaseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

    // There are multiple ways to secure API keys in production:
    // 1) Perhaps the simplest way is to add an application restriction: see
    //      https://developers.google.com/maps/documentation/ios-sdk/get-api-key#step_2_add_the_api_key_to_your_app
    // 2) For more sophisticated ways, see: https://www.reddit.com/r/iOSProgramming/comments/5xh7my/how_do_you_securely_store_api_keys/
    private static let apiKey = Constants.LocationPromptApiKey

    /// Decides if the user should receive a prompt to record a transaction.
    /// - Parameters:
    ///     - userLocation: The user's current location.
    ///     - term: A keyword to be matched against all content that Google has indexed for a place.
    ///         This includes: name, type, and address, customer reviews, and other third-party content.
    ///     - callback: This will be fired after LocationPrompt makes a decision.
    ///         It will be called with `true` if the user should be prompted, and `false` otherwise.
    static func shouldPromptUser(location: CLLocation,
                                 term: String,
                                 callback: @escaping (Bool) -> Void) {
        let parameters = generateRequestParameters(location: location, term: term)

        log.info("Sending Alamofire request.")
        Alamofire
            .request(LocationPrompt.apiBaseUrl, parameters: parameters)
            .validate()
            .responseJSON { response in
                log.info("Received request response.")
                switch response.result {
                case .failure(let error):
                    log.warning("Request unsuccessful. Error=\(error)")
                    callback(false) // Don't notify user if request is unsuccessful

                case .success(let value):
                    log.info("Request successful.")
                    let decision = handleResponse(value)
                    callback(decision)
                }
            }
    }

    /// Generates a dictionary representing Alamofire request parameters.
    private static func generateRequestParameters(location: CLLocation, term: String) -> [String: String] {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        return ["key": LocationPrompt.apiKey,
                "keyword": term,
                "location": String(latitude) + "," + String(longitude),
                "radius": String(Constants.LocationPromptRadius)]
    }

    // This method contains the logic to handle the response from a request to Google Places' API.
    // This could be modified or extended in the future to support machine learning for more accurate predictions.
    private static func handleResponse(_ response: Any) -> Bool {
        let json = JSON(response)

        print(json["results"].arrayValue.count)
        return true // Placeholder response
    }

}
