//
//  StorageCouchBaseDB+TagAssociation.swift
//  bacon
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

    private func getAssociationIdFromQuery(_ query: Query) throws -> [String] {
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
                StorageCouchBaseDB.getAssociationIDFromQuery():
                Encounter error loading associations from database.
                Throwing StorageError.
            """)
            throw StorageError(message: "Transaction-Tag association couldn't be loaded from database.")
        }
    }

    private func getAllAssociationIdOfTransaction(withId uid: String) throws -> [String] {
        // Get all associations stored in the database that belongs to this transaction
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(tagAssociationDatabase))
            .where(Expression.property(Constants.transactionKey).equalTo(Expression.string(uid)))
        let documentIds = try getAssociationIdFromQuery(query)
        log.info("""
            StorageCouchBaseDB.getAllAssociationIdOfTransaction() with argument:
            uid:\(uid).
            """)
        return documentIds
    }

    // To be called when transactions are deleted by the user
    func clearTransactionAssociation(forTransactionWithId uid: String) throws {
        // Get all associations' uid stored in the database that belongs to this transaction
        let documentIds = try getAllAssociationIdOfTransaction(withId: uid)
        log.info("""
            StorageCouchBaseDB.clearTransactionAssociation() with argument:
            uid:\(uid).
        """)
        for documentId in documentIds {
            // Fetch the specific document from database
            guard let associationDocument = tagAssociationDatabase.document(withID: documentId) else {
                log.warning("""
                    StorageCouchBaseDB.clearTransactionAssociation():
                    Encounter error clearing transaction from tag-transaction association database.
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
                    StorageCouchBaseDB.clearTransactionAssociation():
                    Encounter error deleting tag-transaction association from database.
                    Throwing StorageError.
                """)
                throw StorageError(message: """
                    Encounter error deleting transaction from tag-transaction association database.
                """)
            }
        }
    }

    // To be called when transaction is updated by the user.
    // Use case : 1. Tags of the specific transaction has been removed.
    //            2. New tags have been added to the transaction.
    func updateTransactionTagAssociation(for transaction: Transaction, withId uid: String) throws {
        let associationDocumentIds = try getAllAssociationIdOfTransaction(withId: uid)
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
            for tags in newTags where tags.internalValue == associationDocument.int64(forKey: Constants.tagValueKey) {
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
