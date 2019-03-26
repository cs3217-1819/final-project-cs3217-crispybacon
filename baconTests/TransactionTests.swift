//
//  TransactionTests.swift
//  baconTests
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class TransactionTests: XCTestCase {
    let testTime = TransactionTime(Date())
    let testFrequency = try! TransactionFrequency(nature: .oneTime)

    func test_init_validInput_success() {
        let transaction = try! Transaction(time: testTime,
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)
        XCTAssertEqual(transaction.time, testTime)
        XCTAssertEqual(transaction.type, .expenditure)
        XCTAssertEqual(transaction.frequency, testFrequency)
        XCTAssertEqual(transaction.category, .bills)
        XCTAssertEqual(transaction.amount, 1)
        XCTAssertEqual(transaction.description, "")
    }

    func test_init_invalidNegativeAmount() {
        XCTAssertThrowsError(try Transaction(time: testTime,
                                             type: .expenditure,
                                             frequency: testFrequency,
                                             category: .bills,
                                             amount: -1)) { (err) in
                                                XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_invalidZeroAmount() {
        XCTAssertThrowsError(try Transaction(time: testTime,
                                             type: .expenditure,
                                             frequency: testFrequency,
                                             category: .bills,
                                             amount: 0)) { (err) in
                                                XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_transaction_equal() {
        let transaction = try! Transaction(date: testDate.addingTimeInterval(100),
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)
        let transaction2 = try! Transaction(date: testDate.addingTimeInterval(100),
                                            type: .expenditure,
                                            frequency: testFrequency,
                                            category: .bills,
                                            amount: 1)
        XCTAssertEqual(transaction, transaction2)
    }
}
