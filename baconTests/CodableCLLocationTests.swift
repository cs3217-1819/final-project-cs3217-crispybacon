//
//  CodableCLLocationTests.swift
//  baconTests
//
//  Created by Fabian Terh on 29/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import XCTest
@testable import bacon

class CodableCLLocationTests: XCTestCase {
    // swiftlint:disable force_try

    func test_equality() {
        // We test for ==, !=, and isEqual()
        XCTAssertTrue(TestUtils.sampleCLLocation1A == TestUtils.sampleCLLocation1B)
        XCTAssertFalse(TestUtils.sampleCLLocation1A != TestUtils.sampleCLLocation1B)
        XCTAssertEqual(TestUtils.sampleCLLocation1A, TestUtils.sampleCLLocation1B)
    }

    func test_inequality() {
        // We test for ==, !=, and isEqual()
        XCTAssertFalse(TestUtils.sampleCLLocation1A == TestUtils.sampleCLLocation2)
        XCTAssertTrue(TestUtils.sampleCLLocation1A != TestUtils.sampleCLLocation2)
        XCTAssertNotEqual(TestUtils.sampleCLLocation1A, TestUtils.sampleCLLocation2)
    }

    func test_encode_decode() {
        let testCodableLocation = CodableCLLocation(TestUtils.sampleCLLocation1A)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(testCodableLocation)

        let decoder = JSONDecoder()
        let decodedLocation = try! decoder.decode(CodableCLLocation.self, from: data)

        XCTAssertEqual(testCodableLocation, decodedLocation)
    }

    // swiftlint:enable force_try
}
