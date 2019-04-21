//
//  BudgetManagerInterface.swift
//  bacon
//
//  An API for all budget related functionalities.
//
//  Created by Travis Ching Jia Yea on 21/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol BudgetManagerInterface {
    /// Saves a budget.
    /// - Throws: Rethrows any errors encountered during the operation.
    func saveBudget(_ budget: Budget) throws

    /// Loads and returns a budget.
    /// - Throws: Rethrows any errors encountered during the operation.
    func loadBudget() throws -> Budget

    /// Deletes a budget.
    /// - Throws: Rethrows any errors encountered during the operation.
    func deleteBudget() throws
}
