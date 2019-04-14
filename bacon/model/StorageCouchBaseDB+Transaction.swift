//
//  StorageCouchBaseDB+Transaction.swift
//  bacon
//
//  This file is an extension to StorageCouchBaseDB
//  that provides methods supporting Transaction activities.
//
//  Created by Travis Ching Jia Yea on 8/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

extension StorageCouchBaseDB {

    func getNumberOfTransactionsInDatabase() -> Double {
        return Double(transactionDatabase.count)
    }

    func clearTransactionDatabase() throws {
        do {
            try transactionDatabase.delete()
            try tagAssociationDatabase.delete()
            transactionMapping.removeAll()
            // Reinitialize database
            transactionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .transactions)
            tagAssociationDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .tagAssociation)
            log.info("Entered method StorageCouchBaseDB.clearTransactionDatabase()")
        } catch {
            if error is StorageError {
                log.info("""
                    StorageCouchBaseDB.clearTransactionDatabase():
                    Encounter error while reinitializing transaction database.
                    Throwing StorageError.
                """)
                throw error
            } else {
                log.info("""
                    StorageCouchBaseDB.clearTransactionDatabase():
                    Encounter error while clearing transaction database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Encounter error while clearing Transaction Database.")
            }
        }
    }

    func saveTransaction(_ transaction: Transaction) throws {
        do {
            let transactionDocument = try createMutableDocument(from: transaction)
            try transactionDatabase.saveDocument(transactionDocument)
            log.info("""
                StorageCouchBaseDB.saveTransaction() with arguments:
                transaction=\(transaction).
                """)
            let transactionId = transactionDocument.id
            try associateTransactionWithTags(for: transaction, withId: transactionId)
        } catch {
            if error is StorageError {
                throw error
            } else {
                log.info("""
                    StorageCouchBaseDB.saveTransaction():
                    Encounter error saving transaction into database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Transaction couldn't be saved into database.")
            }
        }
    }

    func updateTransaction(_ transaction: Transaction) throws {
        // Fetch the specific document from database
        guard let transactionId = transactionMapping[transaction] else {
            log.warning("""
                    StorageCouchBaseDB.updateTransaction():
                    Encounter error updating transaction in database.
                    Unable to find mapping of transaction object to its unique id in the database.
                    Throwing StorageError.
                """)
            throw StorageError(message: """
                    Unable to find mapping of transaction object to its unique id in the database.
                """)
        }
        let transactionDocument = try createMutableDocument(from: transaction, uid: transactionId)
        log.info("""
            StorageCouchBaseDB.updateTransaction() with argument:
            transaction:\(transaction).
            """)
        // Update the document
        do {
            try transactionDatabase.saveDocument(transactionDocument)
            try updateTransactionTagAssociation(for: transaction, withId: transactionId)
        } catch {
            log.warning("""
                StorageCouchBaseDB.updateTransaction() with argument:
                transaction:\(transaction).
                Encounter error updating transaction in database.
                Throwing StorageError.
                """)
            throw StorageError(message: """
                Encounter error updating \(transaction) in database.
                """)
        }
    }

    func deleteTransaction(_ transaction: Transaction) throws {
        // Fetch the specific document from database
        guard let transactionId = transactionMapping[transaction] else {
            log.info("""
                StorageCouchBaseDB.deleteTransaction():
                Encounter error deleting transaction from database.
                Unable to find mapping of transaction object to its unique id in the database.
                Throwing StorageError.
            """)
            throw StorageError(message: """
                Unable to find mapping of transaction object to its unique id in the database.
            """)
        }
        guard let transactionDocument = transactionDatabase.document(withID: transactionId) else {
            log.info("""
                StorageCouchBaseDB.deleteTransaction():
                Encounter error deleting transaction from database.
                Unable to retrieve transaction document in database using id from mapping.
                Throwing StorageError.
            """)
            throw StorageError(message: """
                Unable to retrieve transaction document in database using id from mapping.
            """)
        }
        log.info("""
            StorageCouchBaseDB.deleteTransaction() with argument:
            transaction:\(transaction).
            """)
        // Delete the document
        do {
            try transactionDatabase.deleteDocument(transactionDocument)
            // Delete the mapping
            transactionMapping.removeValue(forKey: transaction)
            try clearAssociationsOfTransaction(uid: transactionId)
        } catch {
            log.info("""
                StorageCouchBaseDB.deleteTransaction() with argument:
                transaction:\(transaction).
                Encounter error deleting transaction from database.
                Throwing StorageError.
                """)
            throw StorageError(message: """
                Encounter error deleting \(transaction) from database.
                """)
        }
    }

    // To be called when a tag has been deleted from TagManager
    func deleteTagFromTransactions(_ tag: Tag) throws {
        let transactionIds = try getAndDeleteTransactionIdsWithTag(tag)
        log.info("""
            StorageCouchBaseDB.deleteTagFromTransactions() with argument:
            tag:\(tag).
            """)
        // Update transactions in database to remove this tag
        let transactions = try loadTransactionsFromIds(transactionIds)
        for (currentTransaction, transactionId) in transactions {
            // Remove the tag from transaction
            var newTags = currentTransaction.tags
            newTags.remove(tag)
            try currentTransaction.edit(tags: newTags)
            // Update transaction to database
            let updatedTransactionDocument = try createMutableDocument(from: currentTransaction, uid: transactionId)
            do {
                try transactionDatabase.saveDocument(updatedTransactionDocument)
            } catch {
                log.warning("""
                    StorageCouchBaseDB.deleteTagFromTransactions() with argument:
                    tag:\(tag).
                    Encounter error updating transaction after removing tag to database.
                    Throwing StorageError.
                    """)
                throw StorageError(message: """
                    Encounter error saving updated transaction after removing tag to database.
                    """)
            }
        }
    }

    private func getTransactionsFromQuery(_ query: Query) throws -> [Transaction] {
        // Every time database is called to load Transactions, we clear the transaction id mapping
        // dictionary.
        // We only allow front end to deal with transactions per call to load method.
        transactionMapping.removeAll(keepingCapacity: true)
        do {
            var transactions: [Transaction] = Array()
            for result in try query.execute().allResults() {
                guard var transactionDictionary =
                    result.toDictionary()[DatabaseCollections.transactions.rawValue] as? [String: Any] else {
                        throw StorageError(message: "Could not read Document loaded from database as Dictionary.")
                }
                transactionDictionary.removeValue(forKey: Constants.rawDateKey)
                let transactionData = try JSONSerialization.data(withJSONObject: transactionDictionary, options: [])
                let currentTransaction = try JSONDecoder().decode(Transaction.self, from: transactionData)
                transactions.append(currentTransaction)

                // Retrieve and store the mapping of transaction to its id in database
                guard let transactionDatabaseId = result.string(forKey: "id") else {
                    throw StorageError(message: "Could not retrieve UID of transaction from database.")
                }
                transactionMapping.updateValue(transactionDatabaseId, forKey: currentTransaction)
            }
            return transactions
        } catch {
            if error is DecodingError {
                log.info("""
                    StorageCouchBaseDB.getTransactionsFromQuery():
                    Encounter error decoding data from database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Data loaded from database couldn't be decoded back as Transactions.")
            } else {
                log.info("""
                    StorageCouchBaseDB.getTransactionsFromQuery():
                    Encounter error loading data from database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Transactions data couldn't be loaded from database.")
            }
        }
    }

    private func loadTransactionsFromIds(_ transactionIds: [String]) throws
        -> [(transaction: Transaction, uid: String)] {
        var transactionAndIdCollection: [(transaction: Transaction, uid: String)] = []
        log.info("loadTransactionsFromIds():")
        for transactionId in transactionIds {
            do {
                // Fetch the specific document from database
                guard let transactionDocument = transactionDatabase.document(withID: transactionId) else {
                    log.warning("""
                        StorageCouchBaseDB.loadTransactionsFromIds():
                        Encounter error removing tag from transaction in database.
                        Unable to retrieve transaction document in database using id.
                        Throwing StorageError.
                    """)
                    throw StorageError(message: """
                        Unable to retrieve transaction document in database using id.
                    """)
                }
                // Reconstruct document as Transaction object
                let transactionDictionary = transactionDocument.toDictionary()
                let transactionData = try JSONSerialization.data(withJSONObject: transactionDictionary, options: [])
                let currentTransaction = try JSONDecoder().decode(Transaction.self, from: transactionData)
                transactionAndIdCollection.append((transaction: currentTransaction, uid: transactionId))
            } catch {
                log.warning("""
                    StorageCouchBaseDB.loadTransactionsFromIds():
                    Encounter error reconstructing transaction objects.
                """)
                throw StorageError(message: """
                    Encounter error reconstructing transaction objects by loading from database using id.
                """)
            }
        }
        return transactionAndIdCollection
    }

    func loadAllTransactions() throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(transactionDatabase))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
        log.info("""
            StorageCouchBaseDB.loadAllTransactions()
            """)
        return try getTransactionsFromQuery(query)
    }

    func loadTransactions(limit: Int) throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(transactionDatabase))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
            .limit(Expression.int(limit))
        log.info("""
            StorageCouchBaseDB.loadTransactions() with arguments:
            limit=\(limit).
            """)
        return try getTransactionsFromQuery(query)
    }

    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(transactionDatabase))
            .where(Expression.property(Constants.rawDateKey).greaterThan(Expression.date(date)))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
            .limit(Expression.int(limit))
        log.info("""
            StorageCouchBaseDB.loadTransactions() with arguments:
            after=\(date) limit=\(limit).
            """)
        return try getTransactionsFromQuery(query)
    }

    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(transactionDatabase))
            .where(Expression.property(Constants.rawDateKey).lessThan(Expression.date(date)))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
            .limit(Expression.int(limit))
        log.info("""
            StorageCouchBaseDB.loadTransactions() with arguments:
            before=\(date) limit=\(limit).
            """)
        return try getTransactionsFromQuery(query)
    }

    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(transactionDatabase))
            .where(Expression.property(Constants.rawDateKey)
                .between(Expression.date(fromDate), and: Expression.date(toDate)))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
        log.info("""
            StorageCouchBaseDB.loadTransactions() with arguments:
            from=\(fromDate) to=\(toDate).
            """)
        return try getTransactionsFromQuery(query)
    }

    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(transactionDatabase))
            .where(Expression.property(Constants.typeKey).equalTo(Expression.string(type.rawValue)))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
            .limit(Expression.int(limit))
        log.info("""
            StorageCouchBaseDB.loadTransactions() with arguments:
            ofType=\(type) limit=\(limit).
            """)
        return try getTransactionsFromQuery(query)
    }

    /**
    func loadTransactions(ofCategory category: TransactionCategory, limit: Int) throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(transactionDatabase))
            .where(Expression.property(Constants.categoryKey).equalTo(Expression.string(category.rawValue)))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
            .limit(Expression.int(limit))
        log.info("""
            StorageCouchBaseDB.loadTransactions() with arguments:
            ofCategory=\(category) limit=\(limit).
            """)
        return try getTransactionsFromQuery(query)
    }
    **/

    func loadTransactions(ofTag tag: Tag) throws -> [Transaction] {
        let transactionIds = try getTransactionIdsWithTag(tag)
        let transactionIdTuples = try loadTransactionsFromIds(transactionIds)
        var transactions: [Transaction] = []
        for (transaction, _) in transactionIdTuples {
            transactions.append(transaction)
        }
        log.info("""
            StorageCouchBaseDB.loadTransactions() with arguments:
            ofTag=\(tag).
        """)
        return transactions
    }
}
