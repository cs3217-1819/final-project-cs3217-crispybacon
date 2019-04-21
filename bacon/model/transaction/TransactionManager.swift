//
//  ModelManager.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class TransactionManager: TransactionManagerInterface {

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
                    if transaction.frequency.nature == .recurring {
                        try updateRecurringTransaction(transaction)
                    } else {
                        try storageManager.updateTransaction(transaction)
                    }
                    transaction.editSuccessCallback()
                } catch {
                    log.warning("""
                        TransactionManager attempt to edit transaction failed.
                        Calling editFailureCallback.
                        """)
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
        if transaction.frequency.nature == .recurring {
            try saveRecurringTransaction(transaction)
        }
    }

    // Save future recurring instances of the transaction given.
    private func saveRecurringTransaction(_ transaction: Transaction) throws {
        guard transaction.frequency.nature == .recurring else {
            throw InvalidArgumentError(message: """
                recordRecurringTransaction() requires transaction to be recurring.
                """)
        }
        let recurringInstances = try generateAllRecurringInstances(of: transaction)
        for transactions in recurringInstances {
            // Save the next recurring transaction
            try storageManager.saveTransaction(transactions)
        }
    }

    /// Generates all subsequent future recurring instances of a transaction
    /// (i.e. the first instance of a recurring transaction is not included)
    private func generateAllRecurringInstances(of transaction: Transaction) throws -> [Transaction] {
        guard transaction.frequency.nature == .recurring else {
            throw InvalidArgumentError(message: """
                generateAllRecurringInstances() requires transaction to be recurring.
                """)
        }
        guard let numberOfTimesToRepeat = transaction.frequency.repeats else {
            fatalError("Transaction is guarded to be recurring, repeats should not be nil.")
        }
        guard let interval = transaction.frequency.interval else {
            fatalError("Transaction is guarded to be recurring, interval should not be nil.")
        }
        var currentTime = transaction.date
        var dateComponents = DateComponents()
        switch interval {
        case .daily:
            dateComponents.day = 1
        case .weekly:
            dateComponents.day = 7
        case .monthly:
            dateComponents.month = 1
        case .yearly:
            dateComponents.year = 1
        }
        var recurringTransactions: [Transaction] = []
        for _ in 1..<numberOfTimesToRepeat {
            // Calculate the date of the next recurring transaction
            guard let nextRecurringDate = Calendar.current.date(byAdding: dateComponents,
                                                                to: currentTime) else {
                fatalError("""
                    Date calculation for future recurring transaction should not fail.
                    """)
            }
            currentTime = nextRecurringDate
            // Create a copy of the transaction and update the date
            let nextTransaction = transaction.duplicate()
            try nextTransaction.edit(date: currentTime)
            recurringTransactions.append(nextTransaction)
        }
        return recurringTransactions
    }

    /// An edited recurring transaction should have its changes
    /// apply across all recurring instances.
    /// We disallow editing the date of a recurring transaction as
    /// users are able to edit a recurring transaction at an arbitrary instance of it,
    /// if we allow user to edit the date, we will be unable to back track and
    /// find out which instance the transaction was edited at.
    /// - requires: date of recurring transaction not modified
    func updateRecurringTransaction(_ transaction: Transaction) throws {
        guard transaction.frequency.nature == .recurring else {
            throw InvalidArgumentError(message: """
                updateRecurringTransaction() requires transaction to be recurring.
                """)
        }
        // Using the updated transaction information, backtrack and set the date
        // to the first instance.
        let firstInstance = try storageManager.loadFirstRecurringInstance(of: transaction)
        let firstRecurringDate = firstInstance.date
        let updatedTransaction = transaction.duplicate()
        try updatedTransaction.edit(date: firstRecurringDate)
        // As number of repeats may have been updated, we use the approach of
        // deleting all records of the outdated recurring transaction
        // and saving the updated one instead of updating directly.
        try deleteAllRecurringInstance(of: transaction)
        try saveTransaction(updatedTransaction)
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

    func loadTransactions(ofTag tag: Tag) throws -> [Transaction] {
        let transactions = try storageManager.loadTransactions(ofTag: tag)
        return observeTransactions(transactions)
    }
}
