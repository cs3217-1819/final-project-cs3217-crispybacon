//
//  StorageCouchBaseDB+Budget.swift
//  bacon
//
//  This file is an extension to StorageCouchBaseDB
//  that provides methods supporting Budget activities.
//
//  Created by Travis Ching Jia Yea on 8/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

extension StorageCouchBaseDB {

    func clearBudgetDatabase() throws {
        do {
            try budgetDatabase.delete()
            // Reinitialize database
            budgetDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .budget)
            log.info("Entered method StorageCouchBaseDB.clearBudgetDatabase()")
        } catch {
            if error is StorageError {
                log.info("""
                    StorageCouchBaseDB.clearBudgetDatabase():
                    Encounter error while reinitializing budget database.
                    Throwing StorageError.
                """)
                throw error
            } else {
                log.info("""
                    StorageCouchBaseDB.clearBudgetDatabase():
                    Encounter error while clearing budget database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Encounter error while clearing Budget Database.")
            }
        }
    }

}
