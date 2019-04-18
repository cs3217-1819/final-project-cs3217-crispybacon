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
    func test_thatItWorks() {
        let expectation = XCTestExpectation(description: "It should work")
        let testLocation = CLLocation(latitude: 1.3189051817407726, longitude: 103.81685275631474) // Bukit Timah Campus
        _ = LocationPrompt.shouldPromptUser(location: testLocation, term: "food") { response in
            XCTAssertTrue(true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

}
