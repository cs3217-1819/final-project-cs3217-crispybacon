//
//  Config.swift
//  bacon
//
//  Created by Lizhi Zhang on 22/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class Constants {
    // Add Transaction Page Constants
    static let defaultTransactionType = TransactionType.expenditure
    static let defaultCategory = TransactionCategory.food
    static let defaultCategoryString = Constants.defaultCategory.rawValue
    static let defaultAmount: Decimal = 0
    static let defaultAmountString = "0"
}
