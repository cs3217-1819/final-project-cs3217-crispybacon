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
import UIKit
@testable import bacon

class TestUtils {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping

    // Tags
    static let tagManager = TagManager.create(testMode: true)

    static let tagBills = Tag("bills")
    static let tagEducation = Tag("education")
    static let tagEntertainment = Tag("entertainment")
    static let tagFood = Tag("food")
    static let tagInvestment = Tag("investment")
    static let tagTransport = Tag("transport")

    // Sample CLLocation instances naming conventions:
    //      - 'sampleCLLocation'
    //      - Number indicates a unique set of CLLocation properties
    //      - Alphabet indicates multiple CLLocation instances with identical properties (optional)
    // --------------------------------------------------

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

    // Sample UIImages for testing:
    // --------------------------------------------------

    static let redHeartJpg = UIImage(named: "red-heart-jpg")!
    static let redHeartPng = UIImage(named: "red-heart-png")!

    // Valid Transactions for testing naming convention:
    //     - 'valid / invalid'
    //     - 'Transaction'
    //     - The field that is constant (with the exception of date)
    //     - The number indicates the ordering of the date in the transaction
    //       (Chronological order)
    //     * Note that excluding the constant field, the rest of the
    //       transaction properties should differ from each other.
    // --------------------------------------------------

    // An array containing ALL valid transactions defined in TestUtils.
    // Remember to update this if you are creating new valid transactions.
    static let validTransactions = [validTransactionExpenditure01,
                                       validTransactionExpenditure02,
                                       validTransactionExpenditure03,
                                       validTransactionExpenditure04,
                                       validTransactionIncome01,
                                       validTransactionIncome02,
                                       validTransactionIncome03,
                                       validTransactionFood01,
                                       validTransactionFood02,
                                       validTransactionFood03,
                                       validTransactionTransportBill01,
                                       validTransactionTransportBill02,
                                       validTransactionTransportBill03,
                                       validTransactionDate01,
                                       validTransactionDate01point2,
                                       validTransactionDate02,
                                       validTransactionDate02point2,
                                       validTransactionDate03]

    // TRANSACTION - TYPE - EXPENDITURE
    static let validTransactionExpenditure01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(0)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagEducation],
                         amount: 10.0,
                         image: CodableUIImage(redHeartJpg),
                         location: CodableCLLocation(sampleCLLocation1A))
    static let validTransactionExpenditure02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(1_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagEntertainment],
                         amount: 5.0,
                         image: CodableUIImage(redHeartPng),
                         location: CodableCLLocation(sampleCLLocation2))
    static let validTransactionExpenditure03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(2_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: .weekly,
                                                              repeats: 2),
                         tags: [tagEntertainment],
                         amount: 5.0)
    static let validTransactionExpenditure04 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(3_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: .weekly,
                                                              repeats: 1),
                         tags: [tagInvestment],
                         amount: 100.0)

    // TRANSACTION - TYPE - INCOME
    static let validTransactionIncome01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(0)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagFood],
                         amount: 25.50)
    static let validTransactionIncome02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(1_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: .monthly,
                                                              repeats: 3),
                         tags: [tagFood],
                         amount: 12.80,
                         image: CodableUIImage(redHeartPng))
    static let validTransactionIncome03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(2_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagBills],
                         amount: 1,
                         location: CodableCLLocation(sampleCLLocation1B))

    // TRANSACTION - TAG - FOOD
    static let validTransactionFood01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(0)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagFood],
                         amount: 69.60)
    static let validTransactionFood02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(1_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: .monthly,
                                                              repeats: 1),
                         tags: [tagFood],
                         amount: 5.00,
                         location: CodableCLLocation(sampleCLLocation1A))
    static let validTransactionFood03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(2_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagFood],
                         amount: 1.50,
                         image: CodableUIImage(redHeartJpg))

    // TRANSACTION - TAG - TRANSPORT
    static let validTransactionTransportBill01 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(3_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagTransport, tagBills],
                         amount: 8.99,
                         location: CodableCLLocation(sampleCLLocation2))
    static let validTransactionTransportBill02 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(4_000)),
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagBills, tagTransport],
                         amount: 5.0)
    static let validTransactionTransportBill03 =
        try! Transaction(date: Date(timeIntervalSince1970: TimeInterval(5_000)),
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: .weekly,
                                                              repeats: 5),
                         tags: [tagTransport, tagBills],
                         amount: 25.0)

    // TRANSACTION - TIME

    // An array containing ALL test dates defined in TestUtils.
    // Remember to update this if you are creating a new valid date object.
    static let testDates = [january1st2019time0800,
                            january1st2019time1000,
                            january2nd2019time1320,
                            january2nd2019time1500,
                            january5th2019time1230]

    static let january1st2019time0800 = Constants.getDateFormatter().date(from: "2019-01-01 08:00:00")!
    static let january1st2019time1000 = Constants.getDateFormatter().date(from: "2019-01-01 10:00:00")!
    static let january2nd2019time1320 = Constants.getDateFormatter().date(from: "2019-01-02 13:20:00")!
    static let january2nd2019time1500 = Constants.getDateFormatter().date(from: "2019-01-02 15:00:00")!
    static let january5th2019time1230 = Constants.getDateFormatter().date(from: "2019-01-05 12:30:00")!

    static let validTransactionDate01 =
        try! Transaction(date: january1st2019time0800,
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagTransport],
                         amount: 12.60)
    static let validTransactionDate01point2 =
        try! Transaction(date: january1st2019time1000,
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagFood],
                         amount: 1.20,
                         location: CodableCLLocation(sampleCLLocation1B))
    static let validTransactionDate02 =
        try! Transaction(date: january2nd2019time1320,
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: .monthly,
                                                              repeats: 3),
                         tags: [tagBills],
                         amount: 150.00,
                         image: CodableUIImage(redHeartPng))
    static let validTransactionDate02point2 =
        try! Transaction(date: january2nd2019time1500,
                         type: .income,
                         frequency: try! TransactionFrequency(nature: .oneTime),
                         tags: [tagFood],
                         amount: 13.70,
                         location: CodableCLLocation(sampleCLLocation1A))
    static let validTransactionDate03 =
        try! Transaction(date: january5th2019time1230,
                         type: .expenditure,
                         frequency: try! TransactionFrequency(nature: .recurring,
                                                              interval: .weekly,
                                                              repeats: 5),
                         tags: [tagTransport],
                         amount: 40.0)

    // VALID BUDGET INSTANCES
    static let validBudget01 =
        try! Budget(from: january1st2019time0800, to: january2nd2019time1320, amount: 15)
    static let validBudget02 =
        try! Budget(from: january2nd2019time1500, to: january5th2019time1230, amount: 23)

    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}
