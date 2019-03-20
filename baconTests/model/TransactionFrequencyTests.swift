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
        let tf = try! TransactionFrequency(nature: .oneTime)
        XCTAssertEqual(tf.nature, .oneTime)
        XCTAssertNil(tf.interval)
        XCTAssertNil(tf.repeats)
    }

    func test_init_oneTime_extraInput() {
        let tf = try! TransactionFrequency(nature: .oneTime, interval: .daily, repeats: 10)
        // Initializer should ignore `interval` and `repeats` arguments when instantiating a oneTime transaction
        XCTAssertEqual(tf.nature, .oneTime)
        XCTAssertNil(tf.interval)
        XCTAssertNil(tf.repeats)
    }

    func test_init_recurring_validInput() {
        let tf = try! TransactionFrequency(nature: .recurring, interval: .daily, repeats: 10)
        XCTAssertEqual(tf.nature, .recurring)
        XCTAssertEqual(tf.interval, .daily)
        XCTAssertEqual(tf.repeats, 10)
    }

    func test_init_recurring_missingInterval() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: nil, repeats: 10)) { (err) in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_recurring_missingRepeats() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: .daily, repeats: nil)) { (err) in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_recurring_invalidNegativeRepeats() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: .daily, repeats: -5)) { (err) in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_recurring_invalidZeroRepeats() {
        XCTAssertThrowsError(try TransactionFrequency(nature: .recurring, interval: .daily, repeats: 0)) { (err) in
            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

}
