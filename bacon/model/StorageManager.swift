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

class StorageManager {
    private var concreteStorage: StorageCouchBaseDB

    init() throws {
        concreteStorage = try StorageCouchBaseDB()
    }

    func getNumberOfTransactionsInDatabase() -> Double {
        return concreteStorage.getNumberOfTransactionsInDatabase()
    }

    func clearTransactionDatabase() throws {
        return try concreteStorage.clearTransactionDatabase()
    }

    func saveTransaction(_ transaction: Transaction) throws {
        try concreteStorage.saveTransaction(transaction)
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
}
