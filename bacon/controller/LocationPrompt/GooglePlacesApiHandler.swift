//
//  GooglePlacesApiHandler.swift
//  bacon
//
//  Created by Fabian Terh on 18/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import Foundation
import Alamofire
import SwiftyJSON

/// An API Handler for Google's Places API.
class GooglePlacesApiHandler: ApiHandler {

    // See: https://developers.google.com/places/web-service/search for documentation
    private let apiBaseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

    // There are multiple ways to secure API keys in production:
    // 1) Perhaps the simplest way is to add an application restriction: see
    //      https://developers.google.com/maps/documentation/ios-sdk/get-api-key#step_2_add_the_api_key_to_your_app
    // 2) For more sophisticated ways, see: https://www.reddit.com/r/iOSProgramming/comments/5xh7my/how_do_you_securely_store_api_keys/
    private let apiKey = Constants.LocationPromptGooglePlacesApiKey

    func sendRequest(currentLocation: CLLocation,
                     decisionHandler: @escaping (Bool) -> Void) {
        let parameters = generateRequestParameters(currentLocation: currentLocation,
                                                   context: Constants.LocationPromptContext)

        log.info("Sending Alamofire request.")
        Alamofire
            .request(apiBaseUrl, parameters: parameters)
            .validate()
            .responseJSON { response in
                log.info("Received request response.")
                switch response.result {
                case .failure(let error):
                    log.warning("Request unsuccessful. Error=\(error)")
                    decisionHandler(false) // Don't notify user if request is unsuccessful

                case .success(let value):
                    log.info("Request successful.")
                    let decision = self.handleResponse(value)
                    decisionHandler(decision)
                }
            }
    }

    /// Generates a dictionary representing Alamofire request parameters.
    private func generateRequestParameters(currentLocation: CLLocation,
                                           context: String) -> [String: String] {
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude

        return ["key": apiKey,
                "keyword": context,
                "location": String(latitude) + "," + String(longitude),
                "radius": String(Constants.LocationPromptRadius)]
    }

    // This method contains the logic to handle the response from a request to Google Places' API.
    // This could be modified or extended in the future to support machine learning for more accurate predictions.
    private func handleResponse(_ response: Any) -> Bool {
        let json = JSON(response)

        // Rudimentary logic: if there is >= 1 place in the specified vicinity
        // matching the term, return true.
        let matchingPlacesCount = json["results"].arrayValue.count

        return matchingPlacesCount >= 1
    }

}
