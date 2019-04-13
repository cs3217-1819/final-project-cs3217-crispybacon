//
//  CoreLogicTests.swift
//  baconTests
//
//  Created by Travis Ching Jia Yea on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class CoreLogicTests: XCTestCase {
    // swiftlint:disable force_try

    func test_init_success() {
        XCTAssertNoThrow(try CoreLogic(tagManager: TagManager.create(testMode: true)))
    }

    func test_getTotalTransactionsRecorded() {
        let coreLogic = try! CoreLogic(tagManager: TagManager.create(testMode: true))
        XCTAssertNoThrow(try coreLogic.clearAllTransactions())
        // getTotalTransactionsRecorded() should return 0 after clearing all transactions
        XCTAssertEqual(coreLogic.getTotalTransactionsRecorded(), 0)
        // Record a transactions
        XCTAssertNoThrow(try coreLogic.recordTransaction(date: TestUtils.january1st2019time0800,
                                                         type: .expenditure,
                                                         frequency: TransactionFrequency(nature: .oneTime),
                                                         tags: [TestUtils.tagFood],
                                                         amount: 16.50,
                                                         description: "",
                                                         image: CodableUIImage(TestUtils.redHeartPng),
                                                         location: CodableCLLocation(TestUtils.sampleCLLocation2)))
        XCTAssertEqual(coreLogic.getTotalTransactionsRecorded(), 1)
    }

    func test_clearAllTransactions() {
        let coreLogic = try! CoreLogic(tagManager: TagManager.create(testMode: true))
        // If there are no transactions recorded, save a transaction
        if coreLogic.getTotalTransactionsRecorded() == 0 {
            XCTAssertNoThrow(try coreLogic.recordTransaction(date: TestUtils.january2nd2019time1320,
                                                             type: .expenditure,
                                                             frequency: TransactionFrequency(nature: .oneTime),
                                                             tags: [TestUtils.tagBills],
                                                             amount: 120.65,
                                                             description: "Electric bill"))
        }
        XCTAssertTrue(coreLogic.getTotalTransactionsRecorded() > 0)
        XCTAssertNoThrow(try coreLogic.clearAllTransactions())
        XCTAssertTrue(coreLogic.getTotalTransactionsRecorded() == 0)
    }

    func test_recordTransaction() {
        let coreLogic = try! CoreLogic(tagManager: TagManager.create(testMode: true))
        XCTAssertNoThrow(try coreLogic.clearAllTransactions())
        XCTAssertEqual(coreLogic.getTotalTransactionsRecorded(), 0)
        let transaction = try! Transaction(date: TestUtils.january5th2019time1230,
                                           type: .income,
                                           frequency: TransactionFrequency(nature: .oneTime),
                                           tags: [TestUtils.tagBills],
                                           amount: 1_200,
                                           description: "Thailand 5 days 4 night.",
                                           image: CodableUIImage(TestUtils.redHeartJpg),
                                           location: CodableCLLocation(TestUtils.sampleCLLocation1A))
        XCTAssertNoThrow(try coreLogic.recordTransaction(date: TestUtils.january5th2019time1230,
                                                         type: .income,
                                                         frequency: TransactionFrequency(nature: .oneTime),
                                                         tags: [TestUtils.tagBills],
                                                         amount: 1_200,
                                                         description: "Thailand 5 days 4 night.",
                                                         image: CodableUIImage(TestUtils.redHeartJpg),
                                                         location: CodableCLLocation(TestUtils.sampleCLLocation1A)))
        // Load the transaction out of database and check if its the one that was saved
        let loadedTransaction = try! coreLogic.loadTransactions(month: 1, year: 2_019)
        XCTAssertTrue(transaction.equals(loadedTransaction[0]))
    }
}
