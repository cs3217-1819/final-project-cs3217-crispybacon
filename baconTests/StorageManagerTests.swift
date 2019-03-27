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

    func test_getNumberOfTransactionsInDatabase() {
        // swiftlint:disable force_try

        let database = try! StorageManager()
        XCTAssertNoThrow(try database.clearTransactionDatabase())
        // Empty database should return 0 for getNumberOfTransactionsInDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Add some transactions into database
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure01))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure02))
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 2)

        // swiftlint:enable force_try
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

    // This Test case might need to be updated when storage deals with transaction ids
    func test_saveTransaction() {
        // swiftlint:disable force_try

        let database = try! StorageManager()
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure01))
        // Load the transaction out of database and check if its the one that was saved
        let loadedTransaction = try! database.loadTransactions(ofType: .expenditure, limit: 1)
        XCTAssertEqual(TestUtils.validTransactionExpenditure01, loadedTransaction.first)

        // swiftlint:enable force_try
    }

    func test_loadTransactions_OfType() {
        // swiftlint:disable force_try

        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Save 3 transactions of type expenditure
        let expenditureTransactions = [TestUtils.validTransactionExpenditure03,
                                       TestUtils.validTransactionExpenditure02,
                                       TestUtils.validTransactionExpenditure01]
        XCTAssertNoThrow(try database.saveTransaction(expenditureTransactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(expenditureTransactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(expenditureTransactions[0]))
        let loadedExpenditureTransaction = try! database.loadTransactions(ofType: .expenditure, limit: 5)
        XCTAssertEqual(loadedExpenditureTransaction.count, 3)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedExpenditureTransaction, expenditureTransactions)

        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Save 3 transactions of type income
        let incomeTransactions = [TestUtils.validTransactionIncome03,
                                  TestUtils.validTransactionIncome02,
                                  TestUtils.validTransactionIncome01]
        XCTAssertNoThrow(try database.saveTransaction(incomeTransactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(incomeTransactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(incomeTransactions[0]))
        let loadedIncomeTransaction = try! database.loadTransactions(ofType: .income, limit: 5)
        XCTAssertEqual(loadedIncomeTransaction.count, 3)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedIncomeTransaction, incomeTransactions)

        // Test limit
        let loadedTransactions = try! database.loadTransactions(ofType: .income, limit: 1)
        XCTAssertEqual(loadedTransactions.count, 1)

        // swiftlint:enable force_try
    }
}
