//
//  StorageMongoDB.swift
//  bacon
//
//  Underlying class of StorageManager to provide all saving and loading functionalities.
//  Uses CouchBaseLiteSwfit to provide a full-featured embedded NoSQL database that runs locally.
//  As the embedded database is saved into the Document Directory,
//  user's data will be automatically backed up to their icloud.
//
//  StorageCouchBaseDB is implemented as a Singleton class.
//
//  Created by Travis Ching Jia Yea on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

enum DatabaseCollections: String {
    case transactions
    case tagAssociation
    case budget
    case predictions
}

class StorageCouchBaseDB {
    static let sharedDatabase: StorageCouchBaseDB? = StorageCouchBaseDB()

    // MARK: - Properties
    var transactionDatabase: Database
    var tagAssociationDatabase: Database
    var budgetDatabase: Database
    var predictionDatabase: Database

    // Dictionary to provide a mapping from instantiated `Transaction` objects
    // to their unique id in the databse.
    var transactionIdMapping: [Transaction: String]

    private init?() {
        // Initialize database
        do {
            transactionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .transactions)
            tagAssociationDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .tagAssociation)
            budgetDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .budget)
            predictionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .predictions)
            transactionIdMapping = [:]
            log.info("""
                StorageCouchBaseDB.init() :
                Initializing singleton instance of couchbase database.
                """)
        } catch {
            log.warning("""
                StorageManager.init() :
                Encounter error initializing couchbase database.
                """)
            return nil
        }
    }

    static func openOrCreateEmbeddedDatabase(name: DatabaseCollections) throws -> Database {
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
                log.warning("""
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
                log.warning("""
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

    // Method to encode a Transaction class to its MutableDocument counterpart
    func createMutableDocument(from transaction: Transaction, uid: String? = nil) throws -> MutableDocument {
        do {
            let transactionData = try transaction.asDictionary()
            // if uid is not provided, a random uid will be assigned to the document
            let transactionDocument = MutableDocument(id: uid, data: transactionData)
            // Even though transaction is encoded with a date,
            // as the encoded date is in a string format,
            // comparison is not supported in the database level.
            // However CouchBase provides support for date objects,
            // so the date is explicitly set here after converting a `Transaction`
            // class into a document.
            transactionDocument.setDate(transaction.date, forKey: Constants.rawDateKey)
            return transactionDocument
        } catch {
            log.warning("""
                StorageCouchBaseDB.createMutableDocument(): transaction
                Encounter error encoding transaction into MutableDocument.
                Throwing StorageError.
                """)
            throw StorageError(message: "Transaction couldn't be encoded into MutableDocument.")
        }
    }

    // Method to encode a Budget struct to its MutableDocument counterpart
    func createMutableDocument(from budget: Budget) throws -> MutableDocument {
        do {
            let budgetData = try budget.asDictionary()
            let budgetDocument = MutableDocument(id: Constants.budgetUID, data: budgetData)
            return budgetDocument
        } catch {
            log.warning("""
                StorageCouchBaseDB.createMutableDocument(): budget
                Encounter error encoding budget into MutableDocument.
                Throwing StorageError.
                """)
            throw StorageError(message: "Budget couldn't be encoded into MutableDocument.")
        }
    }

    // Method to encode a Prediction struct to its MutableDocument counterpart
    func createMutableDocument(from prediction: Prediction) throws -> MutableDocument {
        do {
            let predictionData = try prediction.asDictionary()
            let predictionDocument = MutableDocument(data: predictionData)
            // Even though prediction is encoded with a date,
            // as the encoded date is in a string format,
            // comparison is not supported in the database level.
            // However CouchBase provides support for date objects,
            // so the date is explicitly set here after converting a `Prediction`
            // struct into a document.
            predictionDocument.setDate(prediction.time, forKey: Constants.rawDateKey)
            return predictionDocument
        } catch {
            log.warning("""
                StorageCouchBaseDB.createMutableDocument(): prediction
                Encounter error encoding prediction into MutableDocument.
                Throwing StorageError.
                """)
            throw StorageError(message: "Prediction couldn't be encoded into MutableDocument.")
        }
    }

    // Method to encode a Transaction-Tag association to its MutableDocument counterpart
    func createMutableDocument(forTransaction transactionId: String, withTag tag: Tag) -> MutableDocument {
        let mutableDocument = MutableDocument()
            .setString(transactionId, forKey: Constants.transactionKey)
            .setInt64(tag.internalValue, forKey: Constants.tagValueKey)
        return mutableDocument
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
