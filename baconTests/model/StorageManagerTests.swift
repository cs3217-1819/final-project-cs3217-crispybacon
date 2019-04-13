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

    func test_getNumberOfBudgetsInDatabase() {
        let database = try! StorageManager()
        XCTAssertNoThrow(try database.clearBudgetDatabase())
        // Empty database should return 0 for getNumberOfBudgetsInDatabase()
        XCTAssertEqual(database.getNumberOfBudgetsInDatabase(), 0)
        // Add budget into database
        XCTAssertNoThrow(try database.saveBudget(TestUtils.validBudget01))
        XCTAssertEqual(database.getNumberOfBudgetsInDatabase(), 1)
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

    func test_clearBudgetDatabase() {
        let database = try! StorageManager()
        // If database is empty, save a budget
        if database.getNumberOfBudgetsInDatabase() == 0 {
            XCTAssertNoThrow(try database.saveBudget(TestUtils.validBudget02))
        }
        XCTAssertTrue(database.getNumberOfBudgetsInDatabase() > 0)
        XCTAssertNoThrow(try database.clearBudgetDatabase())
        XCTAssertTrue(database.getNumberOfBudgetsInDatabase() == 0)
    }

    func test_saveTransaction() {
        let database = try! StorageManager()
        XCTAssertNoThrow(try database.clearTransactionDatabase())
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionExpenditure01))
        // Load the transaction out of database and check if its the one that was saved
        let loadedTransaction = try! database.loadTransactions(ofType: .expenditure, limit: 1)
        XCTAssertTrue(TestUtils.validTransactionExpenditure01.equals(loadedTransaction[0]))
    }

    func test_saveBudget() {
        let database = try! StorageManager()
        XCTAssertNoThrow(try database.clearBudgetDatabase())
        XCTAssertEqual(database.getNumberOfBudgetsInDatabase(), 0)
        XCTAssertNoThrow(try database.saveBudget(TestUtils.validBudget01))
        // Load the budget out of database and check if its the one that was saved
        let budget = try! database.loadBudget()
        XCTAssertEqual(budget, TestUtils.validBudget01)

        // Test that calling saveBudget again will overwrite existing data and not add on to it
        XCTAssertNoThrow(try database.saveBudget(TestUtils.validBudget02))
        let updatedBudget = try! database.loadBudget()
        XCTAssertEqual(updatedBudget, TestUtils.validBudget02)
    }

    func test_deleteTransaction() {
        let database = try! StorageManager()
        // Clear database
        XCTAssertNoThrow(try database.clearTransactionDatabase())
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test deleting empty database
        XCTAssertThrowsError(try database.deleteTransaction(TestUtils.validTransactionDate01))
        // Save some transactions
        let transactions = [TestUtils.validTransactionDate03,
                            TestUtils.validTransactionDate02,
                            TestUtils.validTransactionDate01]
        XCTAssertNoThrow(try database.saveTransaction(transactions[1]))
        XCTAssertNoThrow(try database.saveTransaction(transactions[2]))
        XCTAssertNoThrow(try database.saveTransaction(transactions[0]))
        // Check transactions are saved in the database
        var loadedTransactions = try! database.loadTransactions(limit: 3)
        XCTAssertEqual(transactions.count, loadedTransactions.count)
        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransactions[index]))
        }

        // Remove 2 transactions
        XCTAssertNoThrow(try database.deleteTransaction(loadedTransactions[2]))
        XCTAssertNoThrow(try database.deleteTransaction(loadedTransactions[1]))
        // Check if the 2 transactions are really deleted
        loadedTransactions = try! database.loadTransactions(limit: 3)
        XCTAssertEqual(loadedTransactions.count, 1)
        XCTAssertTrue(transactions[0].equals(loadedTransactions[0]))
    }

    func test_loadAllTransactions() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadAllTransactions().isEmpty)

        // Save multiple transactions
        let transactions = [TestUtils.validTransactionDate03,
                            TestUtils.validTransactionDate02,
                            TestUtils.validTransactionDate01]
        for transaction in transactions {
            XCTAssertNoThrow(try database.saveTransaction(transaction))
        }
        let loadedTransactions = try! database.loadAllTransactions()
        XCTAssertEqual(transactions.count, loadedTransactions.count)
        // Check that the transactions loaded out are equal and in reverse chronological order
        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransactions[index]))
        }
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
        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransactions[index]))
        }
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
        let transactions = [TestUtils.validTransactionDate03,
                            TestUtils.validTransactionDate01point2]
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01point2))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate03))
        let loadedTransactions = try! database.loadTransactions(after: TestUtils.january1st2019time0800, limit: 5)
        XCTAssertEqual(loadedTransactions.count, 2)
        // Check that the transactions loaded out are equal and in reverse chronological order
        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransactions[index]))
        }

        // Test limit
        let limitedTransactions = try! database.loadTransactions(after: TestUtils.january1st2019time0800, limit: 1)
        XCTAssertEqual(limitedTransactions.count, 1)
    }

    func test_invalid_loadTransactions_after() {
        let database = try! StorageManager()
        XCTAssertThrowsError(try database.loadTransactions(after: TestUtils.january5th2019time1230, limit: -1))
    }

    func test_loadTransactions_before() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadTransactions(before: TestUtils.january1st2019time0800, limit: 10).isEmpty)
        XCTAssertTrue(try database.loadTransactions(before: TestUtils.january1st2019time0800, limit: 0).isEmpty)

        // Save transactions
        let transactions = [TestUtils.validTransactionDate01point2,
                            TestUtils.validTransactionDate01]
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01point2))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate03))
        let loadedTransactions = try! database.loadTransactions(before: TestUtils.january5th2019time1230, limit: 5)
        XCTAssertEqual(loadedTransactions.count, 2)
        // Check that the transactions loaded out are equal and in reverse chronological order
        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransactions[index]))
        }

        // Test limit
        let limitedTransactions = try! database.loadTransactions(before: TestUtils.january5th2019time1230, limit: 1)
        XCTAssertEqual(limitedTransactions.count, 1)
    }

    func test_invalid_loadTransactions_before() {
        let database = try! StorageManager()
        XCTAssertThrowsError(try database.loadTransactions(before: TestUtils.january5th2019time1230, limit: -3))
    }

    func test_loadTransactions_from_to() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadTransactions(from: TestUtils.january1st2019time0800,
                                                    to: TestUtils.january5th2019time1230).isEmpty)

        // Save transactions
        let transactions = [TestUtils.validTransactionDate02point2,
                            TestUtils.validTransactionDate02,
                            TestUtils.validTransactionDate01point2]
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate01point2))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate02))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate02point2))
        XCTAssertNoThrow(try database.saveTransaction(TestUtils.validTransactionDate03))
        let loadedTransactions = try! database.loadTransactions(from: TestUtils.january1st2019time1000,
                                                                to: TestUtils.january2nd2019time1500)
        XCTAssertEqual(loadedTransactions.count, 3)
        // Check that the transactions loaded out are equal and in reverse chronological order
        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransactions[index]))
        }
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
        for (index, transaction) in expenditureTransactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedExpenditureTransactions[index]))
        }

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
        for (index, transaction) in incomeTransactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedIncomeTransactions[index]))
        }

        // Test limit
        let loadedTransactions = try! database.loadTransactions(ofType: .income, limit: 1)
        XCTAssertEqual(loadedTransactions.count, 1)
    }

    func test_invalid_loadTransactions_OfType() {
        let database = try! StorageManager()
        XCTAssertThrowsError(try database.loadTransactions(ofType: .expenditure, limit: -1))
    }

    /**
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
        for (index, transaction) in foodTransactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedFoodTransactions[index]))
        }

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
        for (index, transaction) in transportTransactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransportTransactions[index]))
        }

        // Test limit
        let loadedTransactions = try! database.loadTransactions(ofCategory: .food, limit: 1)
        XCTAssertEqual(loadedTransactions.count, 1)
    }

    func test_invalid_loadTransactions_OfCategory() {
        let database = try! StorageManager()
        XCTAssertThrowsError(try database.loadTransactions(ofCategory: .travel, limit: -1))
    }
    **/

    func test_loadTransactions_OfTags() {
        let database = try! StorageManager()
        // Clear database
        try! database.clearTransactionDatabase()
        XCTAssertEqual(database.getNumberOfTransactionsInDatabase(), 0)
        // Test loading empty database
        XCTAssertTrue(try database.loadTransactions(ofTags: TestUtils.foodTagSet).isEmpty)

        // Save 6 transactions of tags "food" "transport" "bill"
        let foodTransactions = [TestUtils.validTransactionFood03,
                                TestUtils.validTransactionFood02,
                                TestUtils.validTransactionFood01]
        let transportBillTransactions = [TestUtils.validTransactionTransportBill03,
                                         TestUtils.validTransactionTransportBill02,
                                         TestUtils.validTransactionTransportBill01]
        let transactions = [TestUtils.validTransactionTransportBill03,
                            TestUtils.validTransactionTransportBill02,
                            TestUtils.validTransactionTransportBill01,
                            TestUtils.validTransactionFood03,
                            TestUtils.validTransactionFood02,
                            TestUtils.validTransactionFood01]
        for transaction in transactions {
            XCTAssertNoThrow(try database.saveTransaction(transaction))
        }

        // Test loading
        let loadedFoodTransactions = try! database.loadTransactions(ofTags: TestUtils.foodTagSet)
        XCTAssertEqual(loadedFoodTransactions.count, foodTransactions.count)
        // Check that the transactions with the tag "food" loaded out are equal and in reverse chronological order
        for (index, transaction) in foodTransactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedFoodTransactions[index]))
        }

        let loadedBillTransactions = try! database.loadTransactions(ofTags: TestUtils.billTagSet)
        XCTAssertEqual(loadedBillTransactions.count, transportBillTransactions.count)
        // Check that the transactions with the tag "bill" loaded out are equal and in reverse chronological order
        for (index, transaction) in transportBillTransactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedBillTransactions[index]))
        }

        let loadedFoodTransportTransactions = try! database.loadTransactions(ofTags: TestUtils.transportFoodTagSet)
        XCTAssertEqual(loadedFoodTransportTransactions.count, transactions.count)
        // Check that the transactions with the tag "transport" or "food"
        // loaded out are equal and in reverse chronological order
        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedFoodTransportTransactions[index]))
        }
    }
    // swiftlint:enable force_try
}
