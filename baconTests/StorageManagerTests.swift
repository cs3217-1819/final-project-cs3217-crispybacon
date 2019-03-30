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
    // swiftlint:disable force_try

    func test_init_success() {
        XCTAssertNoThrow(try StorageManager())
    }

    func test_getNumberOfTransactionsInDatabase() {
        let database = try! StorageManager()
        XCTAssertNoThrow(try database.clearTransactionDatabase())
        // Empty database should return 0 for getNumberOfTransactionsInDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Add some transactions into database
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure01))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure02))
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 2)
    }

    func test_clearTransactionDatabase() {
        let database = try! StorageManager()
        // If database is empty, save a transaction
        if database.getNumberOfTransactionsInDatabase() == 0 {
            XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure01))
        }
        XCTAssertTrue(database.getNumberOfTransactionsInDatabase() > 0)
        XCTAssertNoThrow(try database.clearTransactionDatabase())
        XCTAssertTrue(database.getNumberOfTransactionsInDatabase() == 0)
    }

    // This Test case might need to be updated when storage deals with transaction ids
    func test_saveTransaction() {
        let database = try! StorageManager()
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure01))
        // Load the transaction out of database and check if its the one that was saved
        let loadedTransaction = try! database.loadTransactions(ofType: .expenditure, limit: 1)
        XCTAssertEqual(TestUtils.validTransactionExpenditure01, loadedTransaction.first)
    }

    func test_loadTransactions_limit() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadTransactions(limit: 10).isEmpty)
        XCTAssertTrue(try database.loadTransactions(limit: 0).isEmpty)

        // Save transactions of different type
        let transactions = [TestUtils.validTransactionExpenditure04,
                            TestUtils.validTransactionExpenditure03,
                            TestUtils.validTransactionIncome02,
                            TestUtils.validTransactionExpenditure01]
        XCTAssertNoThrow(try database.saveTransaction(transactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(transactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(transactions[0]))
        XCTAssertNoThrow(try database.saveTransaction(transactions[3]))
        let loadedTransactions = try! database.loadTransactions(limit: 4)
        XCTAssertEqual(loadedTransactions.count, 4)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedTransactions, transactions)
    }

    func test_invalid_loadTransactions_limit() {
        let database = try! StorageManager()
        XCTAssertThrowsError(try database.loadTransactions(limit: -1))
    }

    func test_loadTransactions_after() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadTransactions(after: TestUtils.january1st2019time0800, limit: 10).isEmpty)
        XCTAssertTrue(try database.loadTransactions(after: TestUtils.january1st2019time0800, limit: 0).isEmpty)

        // Save transactions
        let transactions = [TestUtils.validTransactionDate02,
                            TestUtils.validTransactionDate01point2]
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01point2))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate02))
        let loadedTransactions = try! database.loadTransactions(after: TestUtils.january1st2019time0800, limit: 5)
        XCTAssertEqual(loadedTransactions.count, 2)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedTransactions, transactions)
    }

    func test_loadTransactions_OfType() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadTransactions(ofType: .income, limit: 10).isEmpty)
        XCTAssertTrue(try database.loadTransactions(ofType: .expenditure, limit: 0).isEmpty)

        // Save 3 transactions of type expenditure
        let expenditureTransactions = [TestUtils.validTransactionExpenditure03,
                                       TestUtils.validTransactionExpenditure02,
                                       TestUtils.validTransactionExpenditure01]
        XCTAssertNoThrow(try database.saveTransaction(expenditureTransactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(expenditureTransactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(expenditureTransactions[0]))
        let loadedExpenditureTransactions = try! database.loadTransactions(ofType: .expenditure, limit: 5)
        XCTAssertEqual(loadedExpenditureTransactions.count, 3)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedExpenditureTransactions, expenditureTransactions)

        // Save 3 transactions of type income
        let incomeTransactions = [TestUtils.validTransactionIncome03,
                                  TestUtils.validTransactionIncome02,
                                  TestUtils.validTransactionIncome01]
        XCTAssertNoThrow(try database.saveTransaction(incomeTransactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(incomeTransactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(incomeTransactions[0]))
        let loadedIncomeTransactions = try! database.loadTransactions(ofType: .income, limit: 5)
        XCTAssertEqual(loadedIncomeTransactions.count, 3)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedIncomeTransactions, incomeTransactions)

        // Test limit
        let loadedTransactions = try! database.loadTransactions(ofType: .income, limit: 1)
        XCTAssertEqual(loadedTransactions.count, 1)
    }

    func test_invalid_loadTransactions_OfType() {
        let database = try! StorageManager()
        XCTAssertThrowsError(try database.loadTransactions(ofType: .expenditure, limit: -1))
    }

    func test_loadTransactions_OfCategory() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadTransactions(ofCategory: .bills, limit: 10).isEmpty)
        XCTAssertTrue(try database.loadTransactions(ofCategory: .bills, limit: 0).isEmpty)

        // Save 3 transactions of category .food
        let foodTransactions = [TestUtils.validTransactionFood03,
                                TestUtils.validTransactionFood02,
                                TestUtils.validTransactionFood01]
        XCTAssertNoThrow(try database.saveTransaction(foodTransactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(foodTransactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(foodTransactions[0]))
        let loadedFoodTransactions = try! database.loadTransactions(ofCategory: .food, limit: 5)
        XCTAssertEqual(loadedFoodTransactions.count, 3)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedFoodTransactions, foodTransactions)

        // Save 3 transactinos of category .transport
        let transportTransactions = [TestUtils.validTransactionTransport03,
                                     TestUtils.validTransactionTransport02,
                                     TestUtils.validTransactionTransport01]
        XCTAssertNoThrow(try database.saveTransaction(transportTransactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(transportTransactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(transportTransactions[0]))
        let loadedTransportTransactions = try! database.loadTransactions(ofCategory: .transport, limit: 3)
        XCTAssertEqual(loadedTransportTransactions.count, 3)
        // Check that the transactions loaded out are equal and in reverse chronological order
        XCTAssertEqual(loadedTransportTransactions, transportTransactions)

        // Test limit
        let loadedTransactions = try! database.loadTransactions(ofCategory: .food, limit: 1)
        XCTAssertEqual(loadedTransactions.count, 1)
    }

    func test_invalid_loadTransactions_OfCategory() {
        let database = try! StorageManager()
        XCTAssertThrowsError(try database.loadTransactions(ofCategory: .travel, limit: -1))
    }

    // swiftlint:enable force_try
}
