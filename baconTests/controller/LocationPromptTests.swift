//
//  LocationPromptTests.swift
//  baconTests
//
//  Created by Fabian Terh on 18/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import XCTest
@testable import bacon

class LocationPromptTests: XCTestCase {

    // This test case is meaningless.
    // It's a driver program for manually checking that the function works as intended.
    func test_driver() {
        let expectation = XCTestExpectation(description: "It should work")
        let testLocation = CLLocation(latitude: 1.318_905_181_740_772_6,
                                      longitude: 103.816_852_756_314_74) // Bukit Timah Campus
        LocationPrompt.shouldPromptUser(currentLocation: testLocation) { response in
            XCTAssertTrue(response)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

}
