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
    /// Returns the number of transactions in the database.
    func getNumberOfTransactionsInDatabase() -> Double

    /// Clears the database of transactions.
    /// - Throws: `StorageError` if an error is encountered during the operation.
    func clearTransactionDatabase() throws

    /// Saves a Transaction to the database.
    /// - Throws: `StorageError` if an error is encountered during the operation.
    func saveTransaction(_ transaction: Transaction) throws

    /// Deletes a Transaction.
    /// This should only be called on Transactions that are loaded out from the database.
    /// - Throws: `StorageError` if this is called and passed a new Transaction object
    /// instantiated directly at run-time.
    func deleteTransaction(_ transaction: Transaction) throws

    /// Deletes all Transaction instances with the same recurring ID.
    func deleteAllRecurringInstances(of transaction: Transaction) throws

    /// Updates a Transaction.
    /// This should only be called on Transactions that are loaded out from the database.
    /// - Throws: `StorageError` if this is called and passed a new Transaction object
    /// instantiated directly at run-time.
    func updateTransaction(_ transaction: Transaction) throws

    /// Loads all the Transactions in the database.
    /// The caller is responsible for ensuring that doing so will not
    /// result in a memory warning or error.
    /// - Returns: All the transactions saved in the database in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws: `StorageError` if an error is encountered during the operation.
    func loadAllTransactions() throws -> [Transaction]

    /// Loads a collection of Transaction objects.
    /// - Parameters:
    ///     - limit: The number of transactions to load. This must not be less than 0.
    /// - Returns: The specified number of transactions in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws:
    ///     - `InvalidArgumentError` if limit < 0.
    ///     - `StorageError` if an error is encountered during the operation.
    func loadTransactions(limit: Int) throws -> [Transaction]

    /// Loads a collection of Transaction objects after the specified date.
    /// - Parameters:
    ///     - date: The boundary date.
    ///     - limit: The number of transactions to load. This must not be less than 0.
    /// - Returns: The specified number of transactions in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws:
    ///     - `InvalidArgumentError` if limit < 0.
    ///     - `StorageError` if an error is encountered during the operation.
    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction]

    /// Loads a collection of Transaction objects before the date specified.
    /// - Parameters:
    ///     - date: The boundary date.
    ///     - limit: The number of transaction to load. This must not be less than 0.
    /// - Returns: The specified number of transactions in reverse chronological order.
    ///     If there are no transactions saved, an empty array is returned.
    /// - Throws:
    ///     - `InvalidArgumentError` if limit < 0.
    ///     - `StorageError` if an error is encountered during the operation.
    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction]

    /// Loads a collection of Transaction objects between the specified dates (inclusive).
    /// - Parameters:
    ///     - from: The start date.
    ///     - to: The end date.
    /// - Returns: All the transactions that fall between the fromDate and toDate (inclusive)
    ///     in reverse chronological order. If there are no transactions in that period,
    ///     an empty array is returned.
    /// - Throws: `StorageError` if an error is encountered during the operation.
    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction]

    /// Loads a collection of Transaction objects of the specified type.
    /// - Parameters:
    ///     - type: The transaction type.
    ///     - limit: The number of transactions to load. This must not be less than 0.
    /// - Returns: The specified number of transactions of the specified type in
    ///     reverse chronological order. If no transactions fulfill the requirement,
    ///     an empty array is returned.
    /// - Throws:
    ///     - `InvalidArgumentError` if limit < 0.
    ///     - `StorageError` if an error is encountered during the operation.
    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction]

    /// Loads a collection of Transaction objects with the tags specified.
    /// - Parameters:
    ///     - tags: The set of tags specified.
    /// - Returns: All transactions that have at least one of the tags specified in
    ///     reverse chronological order. If no transactions fulfill the requirement,
    ///     an empty array is returned.
    /// - Throws: `StorageError` if an error is encountered during the operation.
    func loadTransactions(ofTag tag: Tag) throws -> [Transaction]

    /// Loads and returns the first Transaction instance of a recurring Transaction object.
    /// - Parameter transaction: This must be a recurring Transaction.
    /// - Throws: `InvalidArgumentError` if `transaction` is a one-time Transaction object.
    func loadFirstRecurringInstance(of transaction: Transaction) throws -> Transaction

    // MARK: Budget Related
    /// Returns the number of budgets in the database.
    func getNumberOfBudgetsInDatabase() -> Double

    /// Clears the database of the budget.
    /// - Throws: `StorageError` if an error is encountered during the operation.
    func clearBudgetDatabase() throws

    /// Saves a budget to the database.
    /// There can only be at most 1 budget existing in the database.
    /// Therefore, this will overwrite any existing budget data.
    /// - Throws: `StorageError` if an error is encountered during the operation.
    func saveBudget(_ budget: Budget) throws

    /// Returns the set budget.
    /// - Throws: `StorageError` if there is no budget.
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
