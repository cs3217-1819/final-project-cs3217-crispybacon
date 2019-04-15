//
//  PredictionTests.swift
//  baconTests
//
//  Created by Lizhi Zhang on 15/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class PredictionTests: XCTestCase {
    // swiftlint:disable force_try
    func test_init_validInput_success() {
        let prediction = try! Prediction(time: TestUtils.january1st2019time0800,
                                         location: CodableCLLocation(TestUtils.sampleCLLocation2),
                                         transactions: TestUtils.validTransactions,
                                         amount: 15.5,
                                         tags: Set<Tag>())
        XCTAssertEqual(prediction.time, TestUtils.january1st2019time0800)
        XCTAssertEqual(prediction.location.location, TestUtils.sampleCLLocation2)
        XCTAssertEqual(prediction.pastTransactions, TestUtils.validTransactions)
        XCTAssertEqual(prediction.amountPredicred, 15.5)
        XCTAssertEqual(prediction.tagsPredicted, Set<Tag>())
    }

    func test_init_invalidNegativeAmount() {
        XCTAssertThrowsError(try Prediction(time: TestUtils.january1st2019time0800,
                                            location: CodableCLLocation(TestUtils.sampleCLLocation2),
                                            transactions: TestUtils.validTransactions,
                                            amount: -1.0,
                                            tags: Set<Tag>())) { err in
                                            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }
    // swiftlint:enable force_try
}
