//
//  StorageMongoDB.swift
//  bacon
//
//  Underlying class of StorageManager to provide all saving and loading functionalities.
//  Uses CouchBaseLiteSwfit to provide a full-featured embedded NoSQL database that runs locally.
//
//  Created by Travis Ching Jia Yea on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

private enum DatabaseCollections: String {
    case transactions
}

class StorageCouchBaseDB {
    static let sharedDatabase: StorageCouchBaseDB? = StorageCouchBaseDB()

    // MARK: - Properties
    private var transactionDatabase: Database
    // Dictionary to provide a mapping from instantiated `Transaction` objects
    // to their unique id in the databse.
    private var transactionMapping: [Transaction: String]

    private init?() {
        // Initialize database
        do {
            transactionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .transactions)
            transactionMapping = [:]
            log.info("""
                StorageCouchBaseDB.init() :
                Initializing singleton instance of couchbase database.
                """)
        } catch {
            log.info("""
                StorageManager.init() :
                Encounter error initializing couchbase database.
                """)
            return nil
        }
    }

    private static func openOrCreateEmbeddedDatabase(name: DatabaseCollections) throws -> Database {
        do {
            let options = DatabaseConfiguration()
            // Get the path to the Database
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let documentDirectory = urls.first else {
                throw InitializationError(message: "unable to access document directory!")
            }
            let databaseFolderUrl = documentDirectory.appendingPathComponent(name.rawValue, isDirectory: true)
            let databaseFolderPath = try getOrCreateFolderPath(for: databaseFolderUrl)
            // Set the folder path for the CouchbaseLite Database
            options.directory = databaseFolderPath
            // Create a new database or get handle to existing database at specified path
            log.info("""
                StorageCouchBaseDB.openOrCreateEmbeddedDatabase() with arguments:
                name=\(name) directory path=\(databaseFolderPath)
                """)
            return try Database(name: name.rawValue, config: options)
        } catch {
            if error is InitializationError {
                throw error
            } else {
                log.info("""
                    StorageCouchBaseDB.openOrCreateEmbeddedDatabase():
                    Encounter error while accessing/creating Database.
                    Throwing InitializationError.
                    """)
                throw InitializationError(message: "unable to access embedded \(name.rawValue) mobile database.")
            }
        }
    }

    private static func getOrCreateFolderPath(for url: URL) throws -> String {
        let folderPath = url.path
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: folderPath) {
            // Create folder if non-existent
            do {
                try fileManager.createDirectory(atPath: folderPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                log.info("""
                    StorageCouchBaseDB.getOrCreateFolderPath()
                    Encounter error while creating directory at \(folderPath).
                    Throwing InitializationError.
                """)
                throw InitializationError(message:
                    "Database directory path is non-existent and encountered error creating directory: \(folderPath)")
            }
        }
        return folderPath
    }

    private func createMutableDocument(from transaction: Transaction) throws -> MutableDocument {
        do {
            let transactionData = try transaction.asDictionary()
            let transactionDocument = MutableDocument(data: transactionData)
            transactionDocument.setDate(transaction.date, forKey: Constants.rawDateKey)
            return transactionDocument
        } catch {
            log.info("""
                StorageCouchBaseDB.createMutableDocument()
                Encounter error encoding transaction into MutableDocument.
                Throwing StorageError.
            """)
            throw StorageError(message: "Transaction couldn't be encoded into MutableDocument.")
        }
    }

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
                let transactionDatabaseId = result.string(forKey: "id")
                if transactionMapping[currentTransaction] == nil {
                    transactionMapping[currentTransaction] = transactionDatabaseId
                }
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
}

// Extension for Encodable to encode codable structs into a dictionary
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
