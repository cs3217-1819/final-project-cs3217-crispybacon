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

    func test_saveTransaction() {
        // swiftlint:disable force_try
        let database = try! StorageManager()
        try! database.clearTransactionDatabase()
        let transaction = try! Transaction(time: TransactionTime(Date()),
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
