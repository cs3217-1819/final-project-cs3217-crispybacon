//
//  BudgetManager.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 9/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class BudgetManager {

    private let storageManager: StorageManager

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
}
