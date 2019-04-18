//
//  ModelManager.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class TransactionManager: Observer {

    private let storageManager: StorageManagerInterface

    init() throws {
        storageManager = try StorageManager()
        log.info("""
            TransactionManager initialized using TransactionManager.init()
            """)
    }

    // Observer is responsible for knowing what object types it observes
    // TransactionManager currently only observes Transactions
    func notify(_ value: Any) {
        // Notified by Transaction
        if let transaction = value as? Transaction {
            // Handle transaction deletion
            if transaction.isDeleted {
                do {
                    // Try deleting it through StorageManager
                    try storageManager.deleteTransaction(transaction)
                    transaction.deleteSuccessCallback()
                } catch {
                    transaction.deleteFailureCallback(error.localizedDescription)
                }
            } else {
                // Handle transaction edit
                do {
                    try storageManager.updateTransaction(transaction)
                    transaction.editSuccessCallback()
                } catch {
                    transaction.editFailureCallback(error.localizedDescription)
                }
            }
            log.info("""
                TransactionManager notified by Transaction: \(transaction)
            """)
            return
        }
        // If program enters here
        // meaning, an error has occured, TransactionManager is notified by
        // objects it doesn't observe.
        log.warning("""
            TransactionManager notified by unidentified object: \(value)
        """)
    }

    private func observeTransactions(_ transactions: [Transaction]) -> [Transaction] {
        transactions.forEach { transaction in transaction.registerObserver(self) }
        return transactions
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

    func deleteTagFromTransactions(_ tag: Tag) throws {
        try storageManager.deleteTagFromTransactions(tag)
    }

    func deleteAllRecurringInstance(of transaction: Transaction) throws {
        try storageManager.deleteAllRecurringInstances(of: transaction)
    }

    func loadTransactions(limit: Int) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(limit: limit)
        return observeTransactions(transactions)
    }

    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(after: date, limit: limit)
        return observeTransactions(transactions)
    }

    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(before: date, limit: limit)
        return observeTransactions(transactions)
    }

    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(from: fromDate, to: toDate)
        return observeTransactions(transactions)
    }

    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(ofType: type, limit: limit)
        return observeTransactions(transactions)
    }

    /**
    func loadTransactions(ofCategory category: TransactionCategory, limit: Int) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(ofCategory: category, limit: limit)
        return observeTransactions(transactions)
    }
    **/

    func loadTransactions(ofTag tag: Tag) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(ofTag: tag)
        return observeTransactions(transactions)
    }
}
