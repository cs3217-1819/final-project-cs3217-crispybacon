//
//  TransactionManagerTests.swift
//  baconTests
//
//  Most methods in TransactionManager just delegates
//  the call to StorageManager() hence we omit most unit test cases and
//  focus more on the logic of saving / updating / deletion of recurring transactions.
//
//  Created by Travis Ching Jia Yea on 19/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class TransactionManagerTests: XCTestCase {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping

    func test_init_success() {
        XCTAssertNoThrow(try TransactionManager())
    }

    func test_saveTransaction_recurring() {
        let transactionManager = try! TransactionManager()
        // Clear database
        XCTAssertNoThrow(try transactionManager.clearTransactionDatabase())
        XCTAssertEqual(transactionManager.getNumberOfTransactionsInDatabase(), 0)
        // Save recurring transaction
        XCTAssertNoThrow(try transactionManager
            .saveTransaction(TestUtils.validTransactionRecurringDaily3Times))
        // Load the transaction out of database and check if its the one that was saved
        let loadedTransactions = try! transactionManager.loadTransactions(limit: 5)
        XCTAssertEqual(loadedTransactions.count, 3)

        // The recurring instances that should have been saved
        let transactionOne = TestUtils.validTransactionRecurringDaily3Times
        let dateTwo = Constants.getDateFormatter().date(from: "2019-01-02 08:00:00")!
        let transactionTwo = transactionOne.duplicate()
        try! transactionTwo.edit(date: dateTwo)
        let dateThree = Constants.getDateFormatter().date(from: "2019-01-03 08:00:00")!
        let transactionThree = transactionOne.duplicate()
        try! transactionThree.edit(date: dateThree)
        let transactions = [transactionThree, transactionTwo, transactionOne]

        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(loadedTransactions[index]))
        }
    }

    func test_updateRecurringTransaction() {
        let transactionManager = try! TransactionManager()
        // Clear database
        XCTAssertNoThrow(try transactionManager.clearTransactionDatabase())
        XCTAssertEqual(transactionManager.getNumberOfTransactionsInDatabase(), 0)
        // Save recurring transaction
        XCTAssertNoThrow(try transactionManager
            .saveTransaction(TestUtils.validTransactionRecurringMonthly5Times))
        XCTAssertEqual(transactionManager.getNumberOfTransactionsInDatabase(), 5)
        let loadedTransaction = try! transactionManager.loadTransactions(limit: 10)
        XCTAssertEqual(loadedTransaction.count, 5)

        // Edit any of the transaction, changing repeats from 5 to 7
        XCTAssertNoThrow(try loadedTransaction[4].edit(frequency: try!
            TransactionFrequency(nature: .recurring,
                                 interval: .monthly,
                                 repeats: 7)))
        // Check that database is updated
        XCTAssertEqual(transactionManager.getNumberOfTransactionsInDatabase(), 7)
        let reloadedTransactions = try! transactionManager.loadTransactions(limit: 10)
        XCTAssertEqual(reloadedTransactions.count, 7)

        // The recurring instances that should have been saved
        let transactionOne = loadedTransaction[4].duplicate()
        let dateTwo = Constants.getDateFormatter().date(from: "2019-02-28 15:00:00")!
        let transactionTwo = transactionOne.duplicate()
        try! transactionTwo.edit(date: dateTwo)
        let dateThree = Constants.getDateFormatter().date(from: "2019-03-28 15:00:00")!
        let transactionThree = transactionOne.duplicate()
        try! transactionThree.edit(date: dateThree)
        let dateFour = Constants.getDateFormatter().date(from: "2019-04-28 15:00:00")!
        let transactionFour = transactionOne.duplicate()
        try! transactionFour.edit(date: dateFour)
        let dateFive = Constants.getDateFormatter().date(from: "2019-05-28 15:00:00")!
        let transactionFive = transactionOne.duplicate()
        try! transactionFive.edit(date: dateFive)
        let dateSix = Constants.getDateFormatter().date(from: "2019-06-28 15:00:00")!
        let transactionSix = transactionOne.duplicate()
        try! transactionSix.edit(date: dateSix)
        let dateSeven = Constants.getDateFormatter().date(from: "2019-07-28 15:00:00")!
        let transactionSeven = transactionOne.duplicate()
        try! transactionSeven.edit(date: dateSeven)
        let transactions = [transactionSeven,
                            transactionSix,
                            transactionFive,
                            transactionFour,
                            transactionThree,
                            transactionTwo,
                            transactionOne]

        for (index, transaction) in transactions.enumerated() {
            XCTAssertTrue(transaction.equals(reloadedTransactions[index]))
        }
    }

    func test_deleteAllRecurringInstances() {
        let transactionManager = try! TransactionManager()
        // Clear database
        XCTAssertNoThrow(try transactionManager.clearTransactionDatabase())
        XCTAssertEqual(transactionManager.getNumberOfTransactionsInDatabase(), 0)
        // Save recurring transaction
        XCTAssertNoThrow(try transactionManager
            .saveTransaction(TestUtils.validTransactionRecurringMonthly5Times))
        XCTAssertEqual(transactionManager.getNumberOfTransactionsInDatabase(), 5)
        // Delete all instances of the specified recurring transaction
        XCTAssertNoThrow(try transactionManager
            .deleteAllRecurringInstance(of: TestUtils.validTransactionRecurringMonthly5Times))
        XCTAssertEqual(transactionManager.getNumberOfTransactionsInDatabase(), 0)
    }
    // swiftlint:enable force_unwrapping
    // swiftlint:enable force_try
}
