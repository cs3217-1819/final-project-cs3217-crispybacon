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
    static let transactionDeleteFailureMessage = "Unable to delete transaction"
    static let tagAddFailureMessage = "Unable to add tag!"
    static let tagEditFailureMessage = "Uable to edit tag!"
    static let tagDeleteFailureMessage = "Unable to delete tag!"
    static let budgetSetFailureMessage = "Unable to set budget!"
    static let budgetStatusFailureMessage = "Unable to update budget status!"
    static let analysisFailureMessage = "Unable to generate analysis!"

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
    static let mainToAnalysis = "mainToAnalysis"

    // Add Transaction Page
    static let defaultTransactionType = TransactionType.expenditure
    static let defaultAmount: Decimal = 0
    static let defaultAmountString = "0"
    static let defaultDescription = ""
    static let oneTime = "One-time"
    static let addTagMessage = "Add tags!"
    static let repeatTimeMessage = "Please specify number of repeat times for this recurring transaction!"
    static let addToMainSuccess = "addToMainSuccess"
    static let addToTagSelection = "addToTagSelection"
    static let addToCalendar = "addToCalendar"
    static let editToTransactions = "editToTransactions"

    // Trsansactions Page
    static let defaultImage = UIImage(named: "dummy")
    static let defaultDescriptionToDisplay = "No description was provided"
    static let defaultTagsToDisplay = "No tags were provided"
    static let animatoinDuration = [0.26, 0.20, 0.20]
    static let imageViewTag = 6
    static let deleteAlertTitle = "Deleting recurring transaction"
    static let deleteAlertMessage = "This is a recurring transaction, do you want to"
    static let deleteSingleMessage = "Delete only this transaction"
    static let deleteAllMessage = "Delete all of this recurring transaction"
    static let transactionsToEdit = "transactionsToEdit"

    // Analysis Page
    static let trendNoDataMessage = "Choose time period to generate monthly trend analysis!"
    static let trendLegend = "Monthly Net Income"
    static let analysisToCalendarFrom = "analysisToCalendarFrom"
    static let analysisToCalendarTo = "analysisToCalendarTo"
    static let analysisToTagBreakDown = "analysisToTagBreakDown"
    static let analysisToLocationSelection = "analysisToLocationSelection"

    // Location Analysis Selection Page
    static let locationSelectionToCalendarFrom = "locationSelectionToCalendarFrom"
    static let locationSelectionToCalendarTo = "locationSelectionToCalendarTo"
    static let locationSelectionToLocationAnalysis = "locationSelectionToLocationAnalysis"

    // Location Analysis Page
    static let heatMapZoom = 13
    static let heatMapRadius = 50

    // Tag Analysis Page
    static let tagNoDataMessage = "Choose tags and time period to generate breakdown analysis!"
    static let tagAnalysisToChooseTag = "tagAnalysisToChooseTag"
    static let tagAnalysisToCalendarFrom = "tagAnalysisToCalendarFrom"
    static let tagAnalysisToCalendarTo = "tagAnalysisToCalendarTo"

    // Tag Selection Page
    static let tagNameInputTitle = "Add new tag"
    static let tagRenameInputTitle = "Edit tag"
    static let tagNameInputMessage = "Enter tag name"
    static let InvalidTagNameWarning = "Please enter a valid name!"
    static let tagSelectionToAdd = "tagSelectionToAdd"
    static let tagSelectionToTagAnalysis = "tagSelectionToTagAnalysis"

    // Set Budget Page
    static let defaultBudgetString = "-1.0"
    static let defaultBudget: Decimal = -1.0
    static let unwindFromBudgetToMain = "unwindFromBudgetToMain"

    // Calendar Page
    static let unwindToAdd = "unwindToAdd"
    static let calendarToAnalysis = "calendarToAnalysis"
    static let calendarToTagAnalysis = "calendarToTagAnalysis"
    static let calendarToLocationAnalysisSelection = "calendarToLocationAnalysisSelection"

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
    static func getYearMonthFormatter() -> DateFormatter {
        return generateFormatter(format: "MMMM yyyy")
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

    // Coding Keys for Transaction fields
    static let typeKey = "type"
    static let tagKey = "tags"
    static let recurringIdKey = "recurringId"
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

    // LocationPrompt
    static let LocationPromptGooglePlacesApiKey = "PLACEHOLDER" // Avoid exposing API key in source code
    static let LocationPromptRadius = 500 // In meters
    static let LocationPromptContext = "food" // Sets the context for deciding whether to prompt a user

    // Background location notifications
    static let notificationIdentifier = "backgroundLocationNotification"
    static let notificationTitle = "Bacon checking in!"
    static let notificationSubtitle = ""
    static let notificationBody = """
        Based on your location, we think you're about to make a transaction.
        """
}
