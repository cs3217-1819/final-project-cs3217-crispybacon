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
                           location: CodableCLLocation?,
                           prediction: Prediction?) throws
    func deleteAllRecurringInstances(of transaction: Transaction) throws
    func loadTransactions(month: Int, year: Int) throws -> [Transaction]

    // MARK: Budget Related
    func saveBudget(_ budget: Budget) throws
    func loadBudget() throws -> Budget
    func getSpendingStatus(_ currentMonthTransactions: [Transaction]) throws -> SpendingStatus

    // MARK: Tag related
    func getTag(for value: String, of parentValue: String?) throws -> Tag
    func getAllTags() -> [Tag: [Tag]]
    func getAllParentTags() -> [Tag]
    func getChildrenTags(of parent: String) throws -> [Tag]
    func addParentTag(_ name: String) throws -> Tag
    func addChildTag(_ child: String, to parent: String) throws -> Tag
    func renameTag(for tag: Tag, to newValue: String) throws -> Tag
    func removeChildTag(_ child: String, from parent: String) throws
    func removeParentTag(_ parent: String) throws

    // MARK: Prediction related
    func getPrediction(_ time: Date, _ location: CodableCLLocation,
                       _ transactions: [Transaction]) -> Prediction?
}
