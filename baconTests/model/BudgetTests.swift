//
//  BudgetTests.swift
//  baconTests
//
//  Created by Travis Ching Jia Yea on 8/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class BudgetTests: XCTestCase {
    // swiftlint:disable force_try
    func test_init_validInput_success() {
        let budget = try! Budget(from: TestUtils.january1st2019time0800,
                                 to: TestUtils.january2nd2019time1320,
                                 amount: 10)
        XCTAssertEqual(budget.fromDate, TestUtils.january1st2019time0800)
        XCTAssertEqual(budget.toDate, TestUtils.january2nd2019time1320)
        XCTAssertEqual(budget.amount, 10)
    }

    func test_init_invalidNegativeAmount() {
        XCTAssertThrowsError(try Budget(from: TestUtils.january1st2019time1000,
                                        to: TestUtils.january5th2019time1230,
                                        amount: -1)) { err in
                                            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_invalidPeriod() {
        // 'from' occurs later than 'to'
        XCTAssertThrowsError(try Budget(from: TestUtils.january5th2019time1230,
                                        to: TestUtils.january1st2019time1000,
                                        amount: 0)) { err in
                                            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
        // 'from' and 'to' are exactly the same
        // Budget is supposed to take in a time period not a single point in time
        XCTAssertThrowsError(try Budget(from: TestUtils.january2nd2019time1320,
                                        to: TestUtils.january2nd2019time1320,
                                        amount: 12)) { err in
                                            XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }
    // swiftlint:enable force_try
}
