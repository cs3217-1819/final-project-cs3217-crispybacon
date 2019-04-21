//
//  StorageManager.swift
//  bacon
//
//  Provides an abstraction over the underlying storage library dependacies.
//  Localizes any changes needed when swapping out the underlying storage library.
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

    func deleteTransaction(_ transaction: Transaction) throws {
        try concreteStorage.deleteTransaction(transaction)
    }

    func deleteAllRecurringInstances(of transaction: Transaction) throws {
        try concreteStorage.deleteAllRecurringInstances(of: transaction)
    }

    func updateTransaction(_ transaction: Transaction) throws {
        try concreteStorage.updateTransaction(transaction)
    }

    func loadAllTransactions() throws -> [Transaction] {
        return try concreteStorage.loadAllTransactions()
    }

    func loadTransactions(limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(limit..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(limit: limit)
    }

    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(after..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(after: date, limit: limit)
    }

    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(before..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(before: date, limit: limit)
    }

    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction] {
        return try concreteStorage.loadTransactions(from: fromDate, to: toDate)
    }

    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction] {
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into LoadTransactions(ofType..) should be non-negative.
                """)
        }
        return try concreteStorage.loadTransactions(ofType: type, limit: limit)
    }

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

    func saveBudget(_ budget: Budget) throws {
        try concreteStorage.saveBudget(budget)
    }

    func loadBudget() throws -> Budget {
        return try concreteStorage.loadBudget()
    }

    // MARK: Tag Related
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
        guard limit >= 0 else {
            throw InvalidArgumentError(message: """
                Limit: \(limit) passed into loadPredictions(limit..) should be non-negative.
                """)
        }
        return try concreteStorage.loadPredictions(limit: limit)
    }
}
