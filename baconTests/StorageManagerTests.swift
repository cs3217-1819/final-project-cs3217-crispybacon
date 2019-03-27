//
//  StorageManagerTests.swift
//  baconTests
//
//  Created by Travis Ching Jia Yea on 23/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class StorageManagerTests: XCTestCase {

    func test_init_success() {
        XCTAssertNoThrow(try StorageManager())
    }

    func test_clearTransactionDatabase() {
        // swiftlint:disable force_try
        let database = try! StorageManager()
        // If database is empty, save a transaction
        if database.getNumberOfTransactionsInDatabase() == 0 {
            XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure01))
        }
        XCTAssertTrue(database.getNumberOfTransactionsInDatabase() > 0)
        XCTAssertNoThrow(try database.clearTransactionDatabase())
        XCTAssertTrue(database.getNumberOfTransactionsInDatabase() == 0)
        // swiftlint:enable force_try
    }

    func test_saveTransaction() {
        // swiftlint:disable force_try
        let database = try! StorageManager()
        try! database.clearTransactionDatabase()
        let transaction = try! Transaction(date: Date(),
                                           type: .expenditure,
                                           frequency: TransactionFrequency(nature: .oneTime),
                                           category: .bills,
                                           amount: 1)
        XCTAssertNoThrow(try database.saveTransaction(transaction))
        let loadedTransaction = try! database.loadTransactions(ofType: .expenditure, limit: 1)
        XCTAssertEqual(transaction, loadedTransaction.first)
        // swiftlint:enable force_try
    }
}
