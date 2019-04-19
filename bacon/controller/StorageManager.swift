//
//  StorageManager.swift
//  bacon
//
//  An API for all storage related functionalities.
//  Provides an abstraction over the underlying storage library dependacies.
//
//  Created by Travis Ching Jia Yea on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class StorageManager: StorageManagerInterface {

    private let concreteStorage: StorageCouchBaseDB

    init() throws {
        guard let sharedDatabase = StorageCouchBaseDB.sharedDatabase else {
            throw StorageError(message: "Unable to access singleton instance of concrete database class")
        }
        concreteStorage = sharedDatabase
        log.info("""
            StorageManager initialized using StorageManager.init()
            """)
    }

    // MARK: Transaction Related
    func getNumberOfTransactionsInDatabase() -> Double {
        return concreteStorage.getNumberOfTransactionsInDatabase()
    }

    func clearTransactionDatabase() throws {
        return try concreteStorage.clearTransactionDatabase()
    }

    func saveTransaction(_ transaction: Transaction) throws {
        try concreteStorage.saveTransaction(transaction)
    }

    /// deleteTransaction() should only be called on Transactions that are loaded
    /// out from database.
    /// Calling delete on a new Transaction object instantiated on run-time
    /// will cause the method to throw a StorageError.
    func deleteTransaction(_ transaction: Transaction) throws {
        try concreteStorage.deleteTransaction(transaction)
    }

    /// Given a recurring transaction, this method clears all transaction instances
    /// with the same recurring id.
    func deleteAllRecurringInstances(of transaction: Transaction) throws {
        try concreteStorage.deleteAllRecurringInstances(of: transaction)
    }

    /// Similar to deleteTransaction(), updateTransaction() should only be called on
    /// Transactions that are loaded out from database.
    func updateTransaction(_ transaction: Transaction) throws {
        try concreteStorage.updateTransaction(transaction)
    }

    /// Loads all the Transactions in the database
    /// - Returns:
    ///     all the transactions saved in the database in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws: `StorageError`
    func loadAllTransactions() throws -> [Transaction] {
        return try concreteStorage.loadAllTransactions()
    }

    /// Loads a collection of Transaction.
    /// - Parameters:
    ///     - limit: The number of transaction to load.
    /// - Returns:
    ///     the specified number of transactions in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws:
    ///     `InvalidArgumentError` if limit < 0
    ///     `StorageError`
    func loadTransactions(limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(limit..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(limit: limit)
    }

    /// Loads a collection of Transaction after the date specified.
    /// - Parameters:
    ///     - date: The boundary date
    ///     - limit: The number of transaction to load.
    /// - Returns:
    ///     the specified number of transactions in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws:
    ///     `InvalidArgumentError` if limit < 0
    ///     `StorageError`
    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(after..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(after: date, limit: limit)
    }

    /// Loads a collection of Transaction before the date specified.
    /// - Parameters:
    ///     - date: The boundary date
    ///     - limit: The number of transaction to load.
    /// - Returns:
    ///     the specified number of transactions in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws:
    ///     `InvalidArgumentError` if limit < 0
    ///     `StorageError`
    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(before..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(before: date, limit: limit)
    }

    /// Loads a collection of Transaction between the 2 dates specified inclusively.
    /// - Parameters:
    ///     - from: The start date
    ///     - to: The end date
    /// - Returns:
    ///     every transactions that fall between the fromDate and toDate inclusively
    ///     in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws: `StorageError`
    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction] {
        return try concreteStorage.loadTransactions(from: fromDate, to: toDate)
    }

    /// Loads a collection of Transaction with the requirements specified.
    /// - Parameters:
    ///     - type: The transaction type.
    ///     - limit: The number of transaction to load.
    /// - Returns:
    ///     the specified number of transactions of the specified type in reverse chronological order.
    ///     If no transactions saved fulfill the requirement, an empty array is returned.
    /// - Throws:
    ///     `InvalidArgumentError` if limit < 0
    ///     `StorageError`
    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(ofType..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(ofType: type, limit: limit)
    }

    /**
     /// Loads a collection of Transaction with the requirements specified.
     /// - Parameters:
     ///     - category: The transaction category.
     ///     - limit: The number of transaction to load.
     /// - Returns:
     ///     the specified number of transactions of the specified category in reverse chronological order.
     ///     If no transactions saved fulfill the requirement, an empty array is returned.
     /// - Throws:
     ///     `InvalidArgumentError` if limit < 0
     ///     `StorageError`
     func loadTransactions(ofCategory category: TransactionCategory, limit: Int) throws -> [Transaction] {
     guard limit >= 0 else {
     throw InvalidArgumentError(message: """
     Limit: \(limit) passed into LoadTransactions(ofCategory..) should be non-negative.
     """)
     }
     return try concreteStorage.loadTransactions(ofCategory: category, limit: limit)
     }
     **/

    /// Loads a collection of Transaction with the tags specified.
    /// - Parameters:
    ///     - tags: The set of tags specified.
    /// - Returns:
    ///     all transactions that have at least one of the tag specified in reverse chronological order.
    ///     If no transactions saved fulfill the requirement, an empty array is returned.
    /// - Throws: `StorageError`
    func loadTransactions(ofTag tag: Tag) throws -> [Transaction] {
        return try concreteStorage.loadTransactions(ofTag: tag)
    }

    func loadFirstRecurringInstance(of transaction: Transaction) throws -> Transaction {
        return try concreteStorage.loadFirstRecurringInstance(of: transaction)
    }

    // MARK: Budget Related
    func getNumberOfBudgetsInDatabase() -> Double {
        return concreteStorage.getNumberOfBudgetsInDatabase()
    }

    func clearBudgetDatabase() throws {
        return try concreteStorage.clearBudgetDatabase()
    }

    /// Saves a budget into the database
    /// There will always only be at most one budget existing in the database
    /// In other words, calling saveBudget will overwrite any existing budget data.
    func saveBudget(_ budget: Budget) throws {
        try concreteStorage.saveBudget(budget)
    }

    func loadBudget() throws -> Budget {
        return try concreteStorage.loadBudget()
    }

    // MARK: Tag Related
    /// deleteTagFromTransactions will remove the specified tag
    /// from all transactions associated with it.
    func deleteTagFromTransactions(_ tag: Tag) throws {
        try concreteStorage.deleteTagFromTransactions(tag)
    }

    // MARK: Prediction Related
    func getNumberOfPredictionsInDatabase() -> Double {
        return concreteStorage.getNumberOfPredictionsInDatabase()
    }

    func clearPredictionDatabase() throws {
        try concreteStorage.clearPredictionDatabase()
    }

    func savePrediction(_ prediction: Prediction) throws {
        try concreteStorage.savePrediction(prediction)
    }

    func loadAllPredictions() throws -> [Prediction] {
        return try concreteStorage.loadAllPredictions()
    }

    func loadPredictions(limit: Int) throws -> [Prediction] {
        return try concreteStorage.loadPredictions(limit: limit)
    }
}
