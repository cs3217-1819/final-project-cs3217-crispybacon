//
//  CoreLogicInterface.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 9/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol CoreLogicInterface {
    // MARK: Transaction Related
    func getTotalTransactionsRecorded() -> Double
    func clearAllTransactions() throws
    func recordTransaction(date: Date,
                           type: TransactionType,
                           frequency: TransactionFrequency,
                           tags: Set<Tag>,
                           amount: Decimal,
                           description: String,
                           image: CodableUIImage?,
                           location: CodableCLLocation?) throws
    func loadTransactions(month: Int, year: Int) throws -> [Transaction]

    // MARK: Budget Related
    func saveBudget(_ budget: Budget) throws
    func loadBudget() throws -> Budget
    func getSpendingStatus() throws -> SpendingStatus

    // Mark: Tag Related
    func getAllTags() -> [Tag: [Tag]]
    func getAllParentTags() -> [Tag]
    func addParentTag(_ name: String) throws -> Tag
    func addChildTag(_ child: String, to parent: String) throws -> Tag
    func removeChildTag(_ child: String, from parent: String) throws
    func removeParentTag(_ parent: String) throws
}
