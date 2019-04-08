//
//  Config.swift
//  bacon
//
//  Created by Lizhi Zhang on 22/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class Constants {
    // Global
    static let currencySymbol = Locale.current.currencySymbol ?? "$"
    static let defaultPostalAddress = CNPostalAddress()
    static let warningTitle = "🐷WARNING🐷"
    static let coreFailureMessage = "Unable to run Bacon!"
    static let transactionAddFailureMessage = "Unable to add transaction!"
    static let transactionLoadFailureMessage = "Unable to load transactions!"

    // Add Transaction Page
    static let defaultTransactionType = TransactionType.expenditure
    static let defaultCategory = TransactionCategory.food
    static let defaultCategoryString = Constants.defaultCategory.rawValue
    static let defaultAmount: Decimal = 0
    static let defaultAmountString = "0"
    static let defaultDescription = ""

    // Trsansactions Page
    static let defaultImage = UIImage(named: "dummy")
    static let animatoinDuration = [0.26, 0.20, 0.20]

    // Date Formatter
    static func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    static func getDateOnlyFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    static func getTimeOnlyFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    // Dictionary Key for Transaction fields for use in Database
    static let typeKey = "type"
    static let categoryKey = "category"
    static let rawDateKey = "rawDate"

    // UID of budget in database
    // There should only be one budget saved in the database
    // Hence saveBudget always uses this UID.
    static let budgetUID = "1"
}
