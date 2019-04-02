//
//  Config.swift
//  bacon
//
//  Created by Lizhi Zhang on 22/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class Constants {
    // Global
    static let currencySymbol = Locale.current.currencySymbol ?? "$"

    // Add Transaction Page Constants
    static let defaultTransactionType = TransactionType.expenditure
    static let defaultCategory = TransactionCategory.food
    static let defaultCategoryString = Constants.defaultCategory.rawValue
    static let defaultAmount: Decimal = 0
    static let defaultAmountString = "0"
    static let defaultDescription = ""

    // Date Formatter
    static func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }

    // Dictionary Key for Transaction fields for use in Database
    static let typeKey = "type"
    static let categoryKey = "category"
    static let rawDateKey = "rawDate"
}
