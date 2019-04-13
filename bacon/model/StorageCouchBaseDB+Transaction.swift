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
            transactionMapping.removeAll()
            // Reinitialize database
            transactionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .transactions)
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

    private func getTransactionsFromQuery(_ query: Query) throws -> [Transaction] {
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

    func loadTransactions(ofTags tags: Set<Tag>) throws -> [Transaction] {
        do {
            let allTransactions = try loadAllTransactions()
            var wantedTransactions: [Transaction] = []
            for transactions in allTransactions {
                for wantedTags in tags where transactions.tags.contains(wantedTags) {
                    wantedTransactions.append(transactions)
                    break
                }
            }
            log.info("""
                StorageCouchBaseDB.loadTransactions() with arguments:
                ofTags=\(tags).
                """)
            return wantedTransactions
        } catch {
            throw StorageError(message: """
                loadTransactions(ofTags) encounter error, underlying calls loadAllTransactions()
            """)
        }
    }
}
