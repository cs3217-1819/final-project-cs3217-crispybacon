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
}
