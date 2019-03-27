//
//  TestUtils.swift
//  baconTests
//
//  TestUtils stores valid instances of class objects for testing.
//
//  Created by Travis Ching Jia Yea on 27/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
@testable import bacon

class TestUtils {
    // swiftlint:disable force_try

    // Valid Transactions for testing naming convention:
    //     - 'valid / invalid'
    //     - 'Transaction'
    //     - The field that is constant
    //     - The number indicates the ordering of the date in the transaction
    //       (Chronological order)
    //     * Note that excluding date and the constant field, the rest of the
    //       transaction properties should differ from each other.
    // --------------------------------------------------

    // TRANSACTION - TYPE - EXPENDITURE
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
    static let validTransactionExpenditure04 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(3_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: TransactionFrequencyInterval.weekly,
                                                              repeats: 1),
                         category: .investment,
                         amount: 100.0)

    // TRANSACTION - TYPE - INCOME
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

    // TRANSACTION - CATEGORY - FOOD
    static let validTransactionFood01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(0)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .food,
                         amount: 69.60)
    static let validTransactionFood02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(1_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: TransactionFrequencyInterval.monthly,
                                                              repeats: 1),
                         category: .food,
                         amount: 5.00)
    static let validTransactionFood03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(2_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .food,
                         amount: 1.50)

    // TRANSACTION - CATEGORY - TRANSPORT
    static let validTransactionTransport01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(0)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .transport,
                         amount: 8.99)
    static let validTransactionTransport02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(1_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         category: .transport,
                         amount: 5.0)
    static let validTransactionTransport03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(2_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: TransactionFrequencyInterval.weekly,
                                                              repeats: 5),
                         category: .transport,
                         amount: 25.0)

    // swiftlint:enable force_try
}
