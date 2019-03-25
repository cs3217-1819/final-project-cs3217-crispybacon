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
        let database = try! StorageManager()
        let transaction = try! Transaction(date: Date(),
                                           type: .expenditure,
                                           frequency: TransactionFrequency(nature: .oneTime),
                                           category: .bills,
                                           amount: 1)
        XCTAssertNoThrow(try database.saveTransaction(transaction))
        // Test that the transaction loaded out is the same
        // Need to modify transaction equality checking
    }
}
