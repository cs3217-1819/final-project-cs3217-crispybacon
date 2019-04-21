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

    // Method for testing to ensure that there is always only 1 budget in database
    func getNumberOfBudgetsInDatabase() -> Double {
        return Double(budgetDatabase.count)
    }

    func clearBudgetDatabase() throws {
        do {
            try budgetDatabase.delete()
            // Reinitialize database
            budgetDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .budget)
            log.info("Entered method StorageCouchBaseDB.clearBudgetDatabase()")
        } catch {
            if error is StorageError {
                log.warning("""
                    StorageCouchBaseDB.clearBudgetDatabase():
                    Encounter error while reinitializing budget database.
                    Throwing StorageError.
                    """)
                throw error
            } else {
                log.warning("""
                    StorageCouchBaseDB.clearBudgetDatabase():
                    Encounter error while clearing budget database.
                    Throwing StorageError.
                    """)
                throw StorageError(message: "Encounter error while clearing Budget Database.")
            }
        }
    }

    func saveBudget(_ budget: Budget) throws {
        do {
            let budgetDocument = try createMutableDocument(from: budget)
            try budgetDatabase.saveDocument(budgetDocument)
            log.info("""
                StorageCouchBaseDB.saveBudget() with arguments:
                budget=\(budget).
                """)
        } catch {
            if error is StorageError {
                throw error
            } else {
                log.info("""
                    StorageCouchBaseDB.saveBudget():
                    Encounter error saving budget into database.
                    Throwing StorageError.
                    """)
                throw StorageError(message: "Budget couldn't be saved into database.")
            }
        }
    }

    func loadBudget() throws -> Budget {
        let query = QueryBuilder.select(SelectResult.all())
            .from(DataSource.database(budgetDatabase))
            .limit(Expression.int(1))
        log.info("""
            StorageCouchBaseDB.loadBudget()
            """)
        return try getBudgetFromQuery(query)
    }

    private func getBudgetFromQuery(_ query: Query) throws -> Budget {
        do {
            guard let result = try query.execute().allResults().first else {
                throw StorageError(message: "There is no Budget saved in database.")
            }
            guard let budgetDictionary =
                result.toDictionary()[DatabaseCollections.budget.rawValue] as? [String: Any] else {
                throw StorageError(message: "Could not read Document loaded from database as Dictionary.")
            }
            let budgetData = try JSONSerialization.data(withJSONObject: budgetDictionary, options: [])
            let budget = try JSONDecoder().decode(Budget.self, from: budgetData)
            return budget
        } catch {
            if error is DecodingError {
                log.warning("""
                    StorageCouchBaseDB.getBudgetFromQuery():
                    Encounter error decoding data from database.
                    Throwing StorageError.
                    """)
                throw StorageError(message: "Data loaded from database couldn't be decoded back as Budget.")
            } else {
                log.warning("""
                    StorageCouchBaseDB.getBudgetFromQuery():
                    Encounter error loading data from database.
                    Throwing StorageError.
                    """)
                throw StorageError(message: "Budget data couldn't be loaded from database.")
            }
        }
    }
}
