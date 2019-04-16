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
    static let currency = Locale.current.currencySymbol ?? "$"
    static let defaultPostalAddress = CNPostalAddress()
    static let warningTitle = "🐷WARNING🐷"
    static let coreFailureMessage = "Unable to run Bacon!"
    static let transactionAddFailureMessage = "Unable to add transaction!"
    static let transactionLoadFailureMessage = "Unable to load transactions!"
    static let transactionEditFailureMessage = "Unable to edit transaction!"
    static let tagAddFailureMessage = "Unable to add tag!"
    static let budgetSetFailureMessage = "Unable to set budget!"
    static let budgetStatusFailureMessage = "Unable to update budget status!"

    // Main Page
    static let neutralPig = UIImage(named: "demo")
    static let happyPig = UIImage(named: "happy")
    static let veryHappyPig = UIImage(named: "happy2")
    static let sadPig = UIImage(named: "unhappy")
    static let verySadPig = UIImage(named: "unhappy2")
    static let mainToAddTransactionEx = "mainToAddTransactionEx"
    static let mainToAddTransactionIn = "mainToAddTransactionIn"
    static let mainToSetBudget = "mainToSetBudget"
    static let mainToTransactions = "mainToTransactions"
    static let mainToTags = "mainToTags"

    // Add Transaction Page
    static let defaultTransactionType = TransactionType.expenditure
    static let defaultCategory = TransactionCategory.food
    static let defaultCategoryString = Constants.defaultCategory.rawValue
    static let defaultAmount: Decimal = 0
    static let defaultAmountString = "0"
    static let defaultDescription = ""
    static let addTagMessage = "Add tags!"
    static let addToMainSuccess = "addToMainSuccess"
    static let addToTagSelection = "addToTagSelection"
    static let editToTransactions = "editToTransactions"

    // Trsansactions Page
    static let defaultImage = UIImage(named: "dummy")
    static let defaultDescriptionToDisplay = "No description was provided"
    static let defaultTagsToDisplay = "No tags were provided"
    static let animatoinDuration = [0.26, 0.20, 0.20]
    static let imageViewTag = 6
    static let transactionsToEdit = "transactionsToEdit"

    // Tag Selection Page
    static let tagNameInputTitle = "Add new tag"
    static let tagNameInputMessage = "Enter tag name"
    static let InvalidTagNameWarning = "Please enter a valid name!"
    static let tagSelectionToAdd = "tagSelectionToAdd"

    // Set Budget Page
    static let defaultBudgetString = "-1.0"
    static let defaultBudget: Decimal = -1.0
    static let unwindFromBudgetToMain = "unwindFromBudgetToMain"

    // Calendar Page
    static let unwindToAdd = "unwindToAdd"

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
    static let tagKey = "tags"
    static let rawDateKey = "rawDate"

    // Database Key for Tag-Transaction Association mapping database
    static let transactionKey = "transactionUID"
    static let tagValueKey = "tagInternalValue"

    // UID of budget in database
    // There should only be one budget saved in the database
    // Hence saveBudget always uses this UID.
    static let budgetUID = "1"

    // Prediction related
    static let timeSimilarityThreshold = 120
    static let locationSimilarityThreshold: Double = 500
    static let defaultPredictedAmount: Decimal = 0.0
    static let numberOfPredictedTags = 3
}
