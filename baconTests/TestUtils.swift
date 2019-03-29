//
//  TestUtils.swift
//  baconTests
//
//  TestUtils stores valid instances of class objects for testing.
//
//  Created by Travis Ching Jia Yea on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import CoreLocation
import Foundation
@testable import bacon

class TestUtils {
    // swiftlint:disable force_try

    // Sample CLLocation instances naming conventions:
    //      - 'sampleCLLocation'
    //      - Number indicates a unique set of CLLocation properties
    //      - Alphabet indicates multiple CLLocation instances with identical properties (optional)

    static let locationTimestamp = Date(timeIntervalSince1970: 1_000)

    static let sampleCLLocation1A = CLLocation(coordinate: CLLocationCoordinate2DMake(1, 2),
                                               altitude: 3,
                                               horizontalAccuracy: 4,
                                               verticalAccuracy: 5,
                                               course: 6,
                                               speed: 7,
                                               timestamp: locationTimestamp)
    static let sampleCLLocation1B = CLLocation(coordinate: CLLocationCoordinate2DMake(1, 2),
                                               altitude: 3,
                                               horizontalAccuracy: 4,
                                               verticalAccuracy: 5,
                                               course: 6,
                                               speed: 7,
                                               timestamp: locationTimestamp)

    static let sampleCLLocation2 = CLLocation(coordinate: CLLocationCoordinate2DMake(2, 3),
                                              altitude: 4,
                                              horizontalAccuracy: 5,
                                              verticalAccuracy: 6,
                                              course: 7,
                                              speed: 8,
                                              timestamp: locationTimestamp)

    // Valid Transactions for testing naming convention:
    //     - 'valid / invalid'
    //     - 'Transaction'
    //     - The field that is constant
    //     - The number indicates the ordering of the date in the transaction
    //       (Chronological order)
    //     * Note that excluding date and the constant field, the rest of the
    //       transaction properties should differ from each other.
    // --------------------------------------------------

    // TRANSACTION - EXPENDITURE
    static let validTransactionExpenditure01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(0)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .education,
                         amount: 10.0)
    static let validTransactionExpenditure02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(1_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .entertainment,
                         amount: 5.0)
    static let validTransactionExpenditure03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(2_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: TransactionFrequencyInterval.weekly,
                                                              repeats: 2),
                         category: .entertainment,
                         amount: 5.0)

    // TRANSACTION - INCOME
    static let validTransactionIncome01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(0)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .food,
                         amount: 25.50)
    static let validTransactionIncome02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(1_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: TransactionFrequencyInterval.monthly,
                                                              repeats: 3),
                         category: .food,
                         amount: 12.80)
    static let validTransactionIncome03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(2_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .bills,
                         amount: 1)

    // swiftlint:enable force_try
}
