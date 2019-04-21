//
//  StorageCouchBaseDB+TagAssociation.swift
//  bacon
//
//  This file is an extension to StorageCouchBaseDB
//  that implements database schema for tag-transaction association.
//
//  Created by Travis Ching Jia Yea on 13/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

extension StorageCouchBaseDB {

    // To be called when transactions are created by the user
    func associateTransactionWithTags(for transaction: Transaction, withId uid: String) throws {
        for tags in transaction.tags {
            try associateTransactionWithTag(forTransaction: uid, withTag: tags)
        }
    }

    private func associateTransactionWithTag(forTransaction uid: String, withTag tag: Tag) throws {
        let associationDocument = createMutableDocument(forTransaction: uid, withTag: tag)
        do {
            try tagAssociationDatabase.saveDocument(associationDocument)
            log.info("""
                StorageCouchBaseDB.associateTransactionWithTag() with arguments:
                uid=\(uid) tag=\(tag).
                """)
        } catch {
            log.warning("""
                StorageCouchBaseDB.associateTransactionWithTag():
                Encounter error saving transaction-tag association into database.
                Throwing StorageError.
                """)
            throw StorageError(message: "Transaction-tag association couldn't be saved into database.")
        }
    }

    private func getQueryOfSpecifiedTag(_ tag: Tag) -> Query {
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(tagAssociationDatabase))
            .where(Expression.property(Constants.tagValueKey).equalTo(Expression.string(tag.internalValue)))
        return query
    }

    /// Retrieves all transaction ids with the specified tag
    func getTransactionIdsWithTag(_ tag: Tag) throws -> [String] {
        let query = getQueryOfSpecifiedTag(tag)
        // Retrieve all transaction ids with this tag
        let transactionIds = try getTransactionIdsFromQuery(query)
        return transactionIds
    }

    /// Retrieves all transaction ids with the specified tag
    /// As well as remove all associations with the specified tag
    func getAndDeleteTransactionIdsWithTag(_ tag: Tag) throws -> [String] {
        let query = getQueryOfSpecifiedTag(tag)
        // Retrieve all transaction ids with this tag
        let transactionIds = try getTransactionIdsFromQuery(query)
        // Remove all associations of this tag
        try clearAssociations(try getAssociationIdsFromQuery(query))
        return transactionIds
    }

    private func getAssociationIdsFromQuery(_ query: Query) throws -> [String] {
        do {
            var associations: [String] = Array()
            for result in try query.execute().allResults() {
                // Retrieve the id of the association in the database
                guard let associationDatabaseId = result.string(forKey: "id") else {
                    throw StorageError(message: "Could not retrieve UID of transaction-tag association from database.")
                }
                associations.append(associationDatabaseId)
            }
            return associations
        } catch {
            log.warning("""
                StorageCouchBaseDB.getAssociationIdsFromQuery():
                Encounter error loading associations from database.
                Throwing StorageError.
                """)
            throw StorageError(message: "Transaction-Tag association couldn't be loaded from database.")
        }
    }

    private func getTransactionIdsFromQuery(_ query: Query) throws -> [String] {
        do {
            var transactions: [String] = Array()
            for result in try query.execute().allResults() {
                guard var associationDictionary =
                    result.toDictionary()[DatabaseCollections.tagAssociation.rawValue] as? [String: Any] else {
                        throw StorageError(message: "Could not read Document loaded from database as Dictionary.")
                }
                guard let transactionId = associationDictionary[Constants.transactionKey] as? String else {
                    throw StorageError(message: "Could not retrieve transaction Id from document.")
                }
                transactions.append(transactionId)
            }
            return transactions
        } catch {
            log.warning("""
                StorageCouchBaseDB.getTransactionIdsFromQuery():
                Encounter error loading associations from database.
                Throwing StorageError.
                """)
            throw StorageError(message: "Transaction-Tag association couldn't be loaded from database.")
        }
    }

    private func getAllAssociationIdsOfTransaction(withId uid: String) throws -> [String] {
        // Get all associations stored in the database that belongs to this transaction
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(tagAssociationDatabase))
            .where(Expression.property(Constants.transactionKey).equalTo(Expression.string(uid)))
        let documentIds = try getAssociationIdsFromQuery(query)
        log.info("""
            StorageCouchBaseDB.getAllAssociationIdsOfTransaction() with argument:
            uid:\(uid).
            """)
        return documentIds
    }

    // To be called when transactions are deleted by the user
    func clearAssociationsOfTransaction(uid: String) throws {
        // Get all associations' uid stored in the database that belongs to this transaction
        let documentIds = try getAllAssociationIdsOfTransaction(withId: uid)
        log.info("""
            StorageCouchBaseDB.clearAssociationsOfTransaction() with argument:
            uid:\(uid).
            """)
        try clearAssociations(documentIds)
    }

    func clearAssociations(_ documentIds: [String]) throws {
        for documentId in documentIds {
            // Fetch the specific document from database
            guard let associationDocument = tagAssociationDatabase.document(withID: documentId) else {
                log.warning("""
                    StorageCouchBaseDB.clearAssociations():
                    Encounter error clearing tag-transaction association from database.
                    Unable to retrieve association document in database using id.
                    Throwing StorageError.
                    """)
                throw StorageError(message: """
                    Unable to retrieve association document in database using id.
                    """)
            }
            // Delete the document
            do {
                try tagAssociationDatabase.deleteDocument(associationDocument)
            } catch {
                log.warning("""
                    StorageCouchBaseDB.clearAssociations():
                    Encounter error deleting tag-transaction association from database.
                    Throwing StorageError.
                    """)
                throw StorageError(message: """
                    Encounter error deleting tag-transaction association from database.
                    """)
            }
        }
    }

    // To be called when transaction is updated by the user.
    // Use case : 1. Tags of the specific transaction has been removed.
    //            2. New tags have been added to the transaction.
    func updateTransactionTagAssociation(for transaction: Transaction, withId uid: String) throws {
        let associationDocumentIds = try getAllAssociationIdsOfTransaction(withId: uid)
        var newTags = transaction.tags
        log.info("""
            StorageCouchBaseDB.updateTransactionTagAssociation() with argument:
            transaction:\(transaction) uid:\(uid).
            """)
        // ----------------------
        // Check for use case (1)
        for documentIds in associationDocumentIds {
            // Fetch the specific document from database
            guard let associationDocument = tagAssociationDatabase.document(withID: documentIds) else {
                log.warning("""
                    StorageCouchBaseDB.clearTransactionAssociation():
                    Encounter error updating tag-transaction association database.
                    Unable to retrieve association document in database using id.
                    Throwing StorageError.
                    """)
                throw StorageError(message: """
                    Unable to retrieve association document in database using id.
                    """)
            }
            // Check to see if this tag association needs to be deleted
            var currentTagIsRemoved = true
            for tags in newTags where tags.internalValue == associationDocument.string(forKey: Constants.tagValueKey) {
                // Tag still exists
                currentTagIsRemoved = false
                newTags.remove(tags)
            }
            if currentTagIsRemoved {
                // Delete the document
                do {
                    try tagAssociationDatabase.deleteDocument(associationDocument)
                } catch {
                    log.warning("""
                        StorageCouchBaseDB.updateTransactionTagAssociation():
                        Encounter error deleting tag-transaction association from database.
                        Throwing StorageError.
                        """)
                    throw StorageError(message: """
                        Encounter error deleting tag-transaction association from database.
                        """)
                }
            }
        }
        // ----------------------
        // Check for use case (2)
        for tags in newTags {
            try associateTransactionWithTag(forTransaction: uid, withTag: tags)
        }
    }
}
