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

    func saveBudget(_ budget: Budget) throws
    func loadBudget() throws -> Budget
    func deleteBudget() throws

}
