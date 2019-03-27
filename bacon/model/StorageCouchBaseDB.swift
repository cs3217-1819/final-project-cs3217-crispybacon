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
    private var transactionDatabase: Database

    init() throws {
        // Initialize database
        transactionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .transactions)
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
                Accessing/Creating Database with the following arguments:
                name=\(name) directory path=\(databaseFolderPath)
                """)
            return try Database(name: name.rawValue, config: options)
        } catch {
            if error is InitializationError {
                throw error
            } else {
                log.info("""
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
            return transactionDocument
        } catch {
            log.info("Encounter error encoding transaction into MutableDocument. Throwing StorageError.")
            throw StorageError(message: "Transaction couldn't be encoded into MutableDocument.")
        }
    }

    func getNumberOfTransactionsInDatabase() -> Double {
        return Double(transactionDatabase.count)
    }

    func clearTransactionDatabase() throws {
        do {
            try transactionDatabase.delete()
            // Reinitialize database
            transactionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .transactions)
            log.info("Transaction Database cleared and reinitialized.")
        } catch {
            if error is StorageError {
                log.info("Encounter error while reinitializing transaction database. Throwing StorageError.")
                throw error
            } else {
                log.info("Encounter error while clearing transaction database. Throwing StorageError.")
                throw StorageError(message: "Encounter error while clearing Transaction Database.")
            }
        }
    }

    func saveTransaction(_ transaction: Transaction) throws {
        do {
            let transactionDocument = try createMutableDocument(from: transaction)
            try transactionDatabase.saveDocument(transactionDocument)
            log.info("Transaction \(transaction) saved into database.")
        } catch {
            if error is StorageError {
                throw error
            } else {
                log.info("Encounter error saving transation into database. Throwing StorageError.")
                throw StorageError(message: "Transaction couldn't be saved into database.")
            }
        }
    }

    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction] {
        let query = QueryBuilder.select(SelectResult.all())
                                .from(DataSource.database(transactionDatabase))
                                .where(Expression.property("type").equalTo(Expression.string(type.rawValue)))
                                .orderBy(Ordering.property("date").descending())
                                .limit(Expression.int(limit))
        do {
            var transactions: [Transaction] = Array()
            for result in try query.execute().allResults() {
                guard let transactionDictionary =
                        result.toDictionary()[DatabaseCollections.transactions.rawValue] as? [String: Any] else {
                    throw StorageError(message: "Could not read Document loaded from database as Dictionary.")
                }
                let transactionData = try JSONSerialization.data(withJSONObject: transactionDictionary, options: [])
                let currentTransaction = try JSONDecoder().decode(Transaction.self, from: transactionData)
                transactions.append(currentTransaction)
            }
            log.info("Loaded \(limit) transactions of type \(type) from database.")
            return transactions
        } catch {
            if error is DecodingError {
                log.info("Encounter error decoding data from database. Throwing StorageError.")
                throw StorageError(message: "Data loaded from database couldn't be decoded back as Transactions.")
            } else {
                log.info("Encounter error loading data from database. Throwing StorageError.")
                throw StorageError(message: "Transactions of type \(type) couldn't be loaded from database.")
            }
        }
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
