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
    static let defaultDescriptionToDisplay = "No description was provided"
    static let animatoinDuration = [0.26, 0.20, 0.20]
    static let imageViewTag = 6

    // Date
    static func getDateFormatter() -> DateFormatter {
        return generateFormatter(format: "yyyy-MM-dd HH:mm:ss")
    }
    static func getDateLessPreciseFormatter() -> DateFormatter {
        return generateFormatter(format: "yyyy-MM-dd HH:mm")
    }
    static func getDateOnlyFormatter() -> DateFormatter {
        return generateFormatter(format: "yyyy-MM-dd")
    }
    static func getTimeOnlyFormatter() -> DateFormatter {
        return generateFormatter(format: "HH:mm")
    }
    static func getYearOnlyFormatter() -> DateFormatter {
        return generateFormatter(format: "yyyy")
    }
    static func getMonthStringOnlyFormatter() -> DateFormatter {
        return generateFormatter(format: "MMMM")
    }
    static private func generateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        return formatter
    }
    // Only 20 years are allowed because it affects loading speed
    // but can always change this part
    // swiftlint:disable force_unwrapping
    static let minDate = getDateFormatter().date(from: "2009-01-01 00:00:00")!
    static let maxDate = getDateFormatter().date(from: "2029-01-01 23:59:59")!
    // swiftlint:enable force_unwrapping

    // Dictionary Key for Transaction fields for use in Database
    static let typeKey = "type"
    static let categoryKey = "category"
    static let rawDateKey = "rawDate"
}
