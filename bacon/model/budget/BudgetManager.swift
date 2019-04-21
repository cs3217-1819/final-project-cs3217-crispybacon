//
//  BudgetManager.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 9/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Manages a budget.
class BudgetManager: BudgetManagerInterface {

    private let storageManager: StorageManagerInterface

    /// Instantiates a BudgetManager.
    /// A BudgetManager is backed internally by a StorageManager.
    /// - Throws: Rethrows any error encountered while instantiating a StorageManager.
    init() throws {
        storageManager = try StorageManager()
        log.info("""
            BudgetManager initialized using BudgetManager.init()
            """)
    }

    func saveBudget(_ budget: Budget) throws {
        try storageManager.saveBudget(budget)
    }

    func loadBudget() throws -> Budget {
        return try storageManager.loadBudget()
    }

    func deleteBudget() throws {
        try storageManager.clearBudgetDatabase()
    }
}
