//
//  BudgetManager.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 9/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class BudgetManager: BudgetManagerInterface {

    private let storageManager: StorageManagerInterface

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
