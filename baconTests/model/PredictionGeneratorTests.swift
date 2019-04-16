//
//  PredictionGeneratorTests.swift
//  baconTests
//
//  Created by Lizhi Zhang on 15/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class PredictionGeneratorTests: XCTestCase {
    // swiftlint:disable force_try
    func test_predict() {
        let generator = PredictionGenerator()
        let pastTransactions = [TestUtils.validTransactionDate01,
                                TestUtils.validTransactionDate01point2,
                                TestUtils.validTransactionDate02,
                                TestUtils.validTransactionDate03,
                                TestUtils.validTransactionDate06point2,
                                TestUtils.validTransactionDate07point2]
        let referenceTime = TestUtils.january5th2019time1230
        let referenceLocation = CodableCLLocation(TestUtils.sampleCLLocation1A)
        var expectedTags = Set<Tag>()
        expectedTags.insert(TestUtils.tagFood)
        expectedTags.insert(TestUtils.tagTransport)
        expectedTags.insert(TestUtils.tagBills)
        let expectedPrediction = try! Prediction(time: referenceTime, location: referenceLocation,
                                                 transactions: pastTransactions, amount: 5.80, tags: expectedTags)
        XCTAssertEqual(generator.predict(referenceTime, referenceLocation, pastTransactions), expectedPrediction)
    }

    func test_predict_with_no_similar_transactions() {
        let generator = PredictionGenerator()
        let pastTransactions = [TestUtils.validTransactionDate01,
                                TestUtils.validTransactionDate01point2,
                                TestUtils.validTransactionDate02,
                                TestUtils.validTransactionDate03,
                                TestUtils.validTransactionDate06point2,
                                TestUtils.validTransactionDate07point2]
        let referenceTime = TestUtils.march26th2019time2025
        let referenceLocation = CodableCLLocation(TestUtils.sampleCLLocation1A)
        let expectedTags = Set<Tag>()
        let expectedPrediction = try! Prediction(time: referenceTime, location: referenceLocation,
                                                 transactions: pastTransactions, amount: 0.00, tags: expectedTags)
        XCTAssertEqual(generator.predict(referenceTime, referenceLocation, pastTransactions), expectedPrediction)
    }

    func test_predict_with_wrap_around_at_midnight() {
        let generator = PredictionGenerator()
        let pastTransactions = [TestUtils.validTransactionDate01,
                                TestUtils.validTransactionDate01point2,
                                TestUtils.validTransactionDate02,
                                TestUtils.validTransactionDate03,
                                TestUtils.validTransactionDate06point2,
                                TestUtils.validTransactionDate07point2,
                                TestUtils.validTransactionDate08point2]
        let referenceTime = TestUtils.march26th2019time2345
        let referenceLocation = CodableCLLocation(TestUtils.sampleCLLocation1A)
        var expectedTags = Set<Tag>()
        expectedTags.insert(TestUtils.tagFood)
        expectedTags.insert(TestUtils.tagTransport)
        let expectedPrediction = try! Prediction(time: referenceTime, location: referenceLocation,
                                                 transactions: pastTransactions, amount: 12.34, tags: expectedTags)
        XCTAssertEqual(generator.predict(referenceTime, referenceLocation, pastTransactions), expectedPrediction)
    }
    // swiftlint:enable force_try
}
