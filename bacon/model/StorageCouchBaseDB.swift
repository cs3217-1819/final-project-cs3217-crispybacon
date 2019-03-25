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
            return try Database(name: name.rawValue, config: options)
        } catch let error {
            if error is InitializationError {
                throw error
            } else {
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
            throw StorageError(message: "Transaction couldn't be encoded into MutableDocument.")
        }
    }

    func saveTransaction(_ transaction: Transaction) throws {
        do {
            let transactionDocument = try createMutableDocument(from: transaction)
            try transactionDatabase.saveDocument(transactionDocument)
        } catch let error {
            if error is StorageError {
                throw error
            } else {
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
                guard let transactionDictonary = result.toDictionary()["transactions"]else {
                    throw StorageError(message: "Transactions of type \(type) couldn't be loaded from database.")
                }
                let transactionData = try JSONSerialization.data(withJSONObject: transactionDictonary, options: [])
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let currentTransaction = try decoder.decode(Transaction.self, from: transactionData)
                transactions.append(currentTransaction)
            }
            return transactions
        } catch let error {
            if error is InitializationError {
                throw error
            } else {
                throw StorageError(message: "Transactions of type \(type) couldn't be loaded from database.")
            }
        }
    }
}

// Extension for Encodable to encode codable structs into a dictionary
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
