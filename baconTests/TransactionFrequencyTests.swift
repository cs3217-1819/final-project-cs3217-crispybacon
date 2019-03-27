//
//  TransactionFrequencyTests.swift
//  baconTests
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class TransactionFrequencyTests: XCTestCase {

    func test_init_oneTime_validInput() {
        // swiftlint:disable force_try
        let transactionFrequency = try! TransactionFrequency(nature: .oneTime)
        // swiftlint:enable force_try
        XCTAssertEqual(transactionFrequency.nature, .oneTime)
        XCTAssertNil(transactionFrequency.interval)
        XCTAssertNil(transactionFrequency.repeats)
    }

    func test_init_oneTime_extraInput() {
        // swiftlint:disable force_try
        let transactionFrequency = try! TransactionFrequency(nature: .oneTime, interval: .daily, repeats: 10)
        // swiftlint:enable force_try
        // Initializer should ignore `interval` and `repeats` arguments when instantiating a oneTime transaction
        XCTAssertEqual(transactionFrequency.nature, .oneTime)
        XCTAssertNil(transactionFrequency.interval)
        XCTAssertNil(transactionFrequency.repeats)
    }

    func test_init_recurring_validInput() {
        // swiftlint:disable force_try
        let transactionFrequency = try! TransactionFrequency(nature: .recurring, interval: .daily, repeats: 10)
        // swiftlint:enable force_try
        XCTAssertEqual(transactionFrequency.nature, .recurring)
        XCTAssertEqual(transactionFrequency.interval, .daily)
        XCTAssertEqual(transactionFrequency.repeats, 10)
    }

    func test_init_recurring_missingInterval() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: nil, repeats: 10)) { err in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_recurring_missingRepeats() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: .daily, repeats: nil)) { err in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_recurring_invalidNegativeRepeats() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: .daily, repeats: -5)) { err in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_recurring_invalidZeroRepeats() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: .daily, repeats: 0)) { err in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

}
