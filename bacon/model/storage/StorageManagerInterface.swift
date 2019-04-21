//
//  StorageManagerInterface.swift
//  bacon
//
//  An API for all storage related functionalities.
//
//  Created by Psychedelia on 17/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol StorageManagerInterface {
    // MARK: Transaction Related
    func getNumberOfTransactionsInDatabase() -> Double
    func clearTransactionDatabase() throws
    func saveTransaction(_ transaction: Transaction) throws

    /// deleteTransaction() should only be called on Transactions that are loaded
    /// out from database.
    /// Calling delete on a new Transaction object instantiated on run-time
    /// will cause the method to throw a StorageError.
    func deleteTransaction(_ transaction: Transaction) throws

    /// Given a recurring transaction, this method clears all transaction instances
    /// with the same recurring id.
    func deleteAllRecurringInstances(of transaction: Transaction) throws

    /// Similar to deleteTransaction(), updateTransaction() should only be called on
    /// Transactions that are loaded out from database.
    func updateTransaction(_ transaction: Transaction) throws

    /// Loads all the Transactions in the database
    /// - Returns:
    ///     all the transactions saved in the database in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws: `StorageError`
    func loadAllTransactions() throws -> [Transaction]

    /// Loads a collection of Transaction.
    /// - Parameters:
    ///     - limit: The number of transaction to load.
    /// - Returns:
    ///     the specified number of transactions in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws:
    ///     `InvalidArgumentError` if limit < 0
    ///     `StorageError`
    func loadTransactions(limit: Int) throws -> [Transaction]

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
    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction]

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
    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction]

    /// Loads a collection of Transaction between the 2 dates specified inclusively.
    /// - Parameters:
    ///     - from: The start date
    ///     - to: The end date
    /// - Returns:
    ///     every transactions that fall between the fromDate and toDate inclusively
    ///     in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws: `StorageError`
    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction]

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
    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction]

    /// Loads a collection of Transaction with the tags specified.
    /// - Parameters:
    ///     - tags: The set of tags specified.
    /// - Returns:
    ///     all transactions that have at least one of the tag specified in reverse chronological order.
    ///     If no transactions saved fulfill the requirement, an empty array is returned.
    /// - Throws: `StorageError`
    func loadTransactions(ofTag tag: Tag) throws -> [Transaction]
    func loadFirstRecurringInstance(of transaction: Transaction) throws -> Transaction

    // MARK: Budget Related
    func getNumberOfBudgetsInDatabase() -> Double
    func clearBudgetDatabase() throws

    /// Saves a budget into the database
    /// There will always only be at most one budget existing in the database
    /// In other words, calling saveBudget will overwrite any existing budget data.
    func saveBudget(_ budget: Budget) throws
    func loadBudget() throws -> Budget

    // MARK: Tag Related
    /// deleteTagFromTransactions will remove the specified tag
    /// from all transactions associated with it.
    func deleteTagFromTransactions(_ tag: Tag) throws

    // MARK: Prediction Related
    func getNumberOfPredictionsInDatabase() -> Double
    func clearPredictionDatabase() throws
    func savePrediction(_ prediction: Prediction) throws
    func loadAllPredictions() throws -> [Prediction]
    func loadPredictions(limit: Int) throws -> [Prediction]
}
