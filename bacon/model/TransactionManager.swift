//
//  ModelManager.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class TransactionManager {
    private let storageManager: StorageManager

    init() throws {
        storageManager = try StorageManager()
        log.info("""
            ModelManager initialized using ModelManager.init()
            """)
    }

    func getNumberOfTransactionsInDatabase() -> Double {
        return storageManager.getNumberOfTransactionsInDatabase()
    }

    func clearTransactionDatabase() throws {
        return try storageManager.clearTransactionDatabase()
    }

    func saveTransaction(_ transaction: Transaction) throws {
        try storageManager.saveTransaction(transaction)
    }

    func loadTransactions(limit: Int) throws -> [Transaction] {
        return try storageManager.loadTransactions(limit: limit)
    }

    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction] {
        return try storageManager.loadTransactions(after: date, limit: limit)
    }

    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction] {
        return try storageManager.loadTransactions(before: date, limit: limit)
    }

    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction] {
        return try storageManager.loadTransactions(from: fromDate, to: toDate)
    }

    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction] {
        return try storageManager.loadTransactions(ofType: type, limit: limit)
    }

    func loadTransactions(ofCategory category: TransactionCategory, limit: Int) throws -> [Transaction] {
        return try storageManager.loadTransactions(ofCategory: category, limit: limit)
    }
}
