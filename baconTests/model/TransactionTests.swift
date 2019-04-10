//
//  TransactionTests.swift
//  baconTests
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

// swiftlint:disable force_try

import XCTest
@testable import bacon

class TransactionTests: XCTestCase {
    let testFrequency = try! TransactionFrequency(nature: .oneTime)

    func test_init_validInput_success() {
        let transaction = try! Transaction(date: TestUtils.january1st2019time0800,
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)
        XCTAssertEqual(transaction.date, TestUtils.january1st2019time0800)
        XCTAssertEqual(transaction.type, .expenditure)
        XCTAssertEqual(transaction.frequency, testFrequency)
        XCTAssertEqual(transaction.category, .bills)
        XCTAssertEqual(transaction.amount, 1)
        XCTAssertEqual(transaction.description, "")
    }

    func test_init_invalidNegativeAmount() {
        XCTAssertThrowsError(try Transaction(date: TestUtils.january1st2019time0800,
                                             type: .expenditure,
                                             frequency: testFrequency,
                                             category: .bills,
                                             amount: -1)) { err in
                                                XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_invalidZeroAmount() {
        XCTAssertThrowsError(try Transaction(date: TestUtils.january1st2019time0800,
                                             type: .expenditure,
                                             frequency: testFrequency,
                                             category: .bills,
                                             amount: 0)) { err in
                                                XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_editTransaction_validProperties() {
        // Stress test with all valid transactions
        // Test with editing multiple properties (3 and 2), and single property
        try! TestUtils.validTransactions.forEach { transaction in
            XCTAssertNoThrow(try transaction.edit(date: TestUtils.january1st2019time0800,
                                                  type: .expenditure,
                                                  frequency: testFrequency))
            XCTAssertNoThrow(try transaction.edit(category: .transport,
                                                  amount: 100))
            XCTAssertNoThrow(try transaction.edit(description: "foo"))
        }
    }

    func test_editTransaction_invalidProperties() {
        // Stress test with all valid transactions
        try! TestUtils.validTransactions.forEach { transaction in
            XCTAssertThrowsError(try transaction.edit(amount: -1)) { err in
                XCTAssertTrue(err is InvalidTransactionError)
            }
        }
    }

    func test_transaction_equal() {
        let transaction = try! Transaction(date: TestUtils.january1st2019time1000,
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)
        let transaction2 = try! Transaction(date: TestUtils.january1st2019time1000,
                                            type: .expenditure,
                                            frequency: testFrequency,
                                            category: .bills,
                                            amount: 1)
        let transaction3 = try! Transaction(date: TestUtils.january1st2019time1000,
                                            type: .income,
                                            frequency: testFrequency,
                                            category: .food,
                                            amount: 3)
        XCTAssertTrue(transaction.equals(transaction2))
        XCTAssertNotEqual(transaction, transaction3)
    }

    func test_transactionObservable() {
        let transaction = try! Transaction(date: TestUtils.january1st2019time1000,
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)

        let observer = DummyObserver()
        transaction.registerObserver(observer)

        XCTAssertEqual(observer.notifiedCount, 0)
        try! transaction.edit(amount: 2) // Set amount to new value
        XCTAssertEqual(observer.notifiedCount, 1)
        try! transaction.edit(amount: 2) // Set amount to same value
        XCTAssertEqual(observer.notifiedCount, 2)
    }

    func test_transactionHashable() {
        let transaction1 = try! Transaction(date: TestUtils.january2nd2019time1500,
                                            type: .expenditure,
                                            frequency: testFrequency,
                                            category: .bills,
                                            amount: 1)
        let transaction2 = try! Transaction(date: TestUtils.january2nd2019time1500,
                                            type: .expenditure,
                                            frequency: testFrequency,
                                            category: .bills,
                                            amount: 1)

        XCTAssertTrue(transaction1.equals(transaction2))

        // We override == to check for ===
        XCTAssertNotEqual(transaction1, transaction2)

        // Hash values should be derived from object identifiers
        XCTAssertNotEqual(transaction1.hashValue, transaction2.hashValue)

        var dict: [Transaction: Int] = [:]
        var set: Set<Transaction> = []

        dict[transaction1] = 1
        dict[transaction2] = 2
        set.insert(transaction1)

        XCTAssertEqual(dict[transaction1], 1)
        XCTAssertEqual(dict[transaction2], 2)
        XCTAssertEqual(set.count, 1)

        set.insert(transaction2)
        XCTAssertEqual(set.count, 2)
    }
}

// swiftlint:enable force_try
