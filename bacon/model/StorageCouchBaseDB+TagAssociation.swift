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
            let associationDocument = createMutableDocument(forTransaction: uid, withTag: tags)
            do {
                try tagAssociationDatabase.saveDocument(associationDocument)
                log.info("""
                    StorageCouchBaseDB.associateTransactionWithTags() with arguments:
                    transaction=\(transaction) uid=\(uid).
                    """)
            } catch {
                log.warning("""
                    StorageCouchBaseDB.associateTransactionWithTags():
                    Encounter error saving transaction-tag association into database.
                    Throwing StorageError.
                """)
                    throw StorageError(message: "Transaction-tag association couldn't be saved into database.")
            }
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

    // To be called when transactions are deleted by the user
    func clearTransactionAssociation(forId uid: String) throws {
        // Get all associations stored in the database that belongs to this transaction
        let query = QueryBuilder.select(SelectResult.all(), SelectResult.expression(Meta.id))
            .from(DataSource.database(tagAssociationDatabase))
            .where(Expression.property(Constants.transactionKey).equalTo(Expression.string(uid)))
        let documentIds = try getAssociationIdFromQuery(query)
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
}
