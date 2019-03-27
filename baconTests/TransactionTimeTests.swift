//
//  TransactionTimeTests.swift
//  baconTests
//
//  Created by Fabian Terh on 26/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class TransactionTimeTests: XCTestCase {

    func test_currentDate() {
        let date = Date()
        let transactionTime = TransactionTime(date)

        let calendar = Calendar.current
        XCTAssertEqual(transactionTime.year, calendar.component(.year, from: date))
        XCTAssertEqual(transactionTime.month, calendar.component(.month, from: date))
        XCTAssertEqual(transactionTime.day, calendar.component(.day, from: date))
        XCTAssertEqual(transactionTime.hour, calendar.component(.hour, from: date))
        XCTAssertEqual(transactionTime.minute, calendar.component(.minute, from: date))
        XCTAssertEqual(transactionTime.second, calendar.component(.second, from: date))
    }

}
