//
//  CoreLogic.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class CoreLogic: CoreLogicInterface {

    // MARK: - Properties
    let transactionManager: TransactionManagerInterface
    let budgetManager: BudgetManagerInterface
    let predictionManager: PredictionManagerInterface
    var tagManager: TagManagerInterface

    init(tagManager: TagManager = TagManager.create(testMode: false)) throws {
        transactionManager = try TransactionManager()
        budgetManager = try BudgetManager()
        predictionManager = try PredictionManager()
        self.tagManager = tagManager
    }

    // MARK: Transaction related
    func getTotalTransactionsRecorded() -> Double {
        return transactionManager.getNumberOfTransactionsInDatabase()
    }

    func clearAllTransactions() throws {
        try transactionManager.clearTransactionDatabase()
    }

    func recordTransaction(date: Date,
                           type: TransactionType,
                           frequency: TransactionFrequency,
                           tags: Set<Tag>,
                           amount: Decimal,
                           description: String,
                           image: CodableUIImage? = nil,
                           location: CodableCLLocation? = nil,
                           prediction: Prediction? = nil) throws {
        let currentTransaction = try Transaction(date: date, type: type, frequency: frequency,
                                                 tags: tags, amount: amount, description: description,
                                                 image: image, location: location)
        log.info("""
            CoreLogic.recordTransaction() with arguments:
            date=\(date) type=\(type) frequency=\(frequency) tags=\(tags) amount=\(amount)
            description=\(description) location=\(location as Optional).
            """)
        try transactionManager.saveTransaction(currentTransaction)
        guard let prediction = prediction else {
            // No prediction was used, hence no need to check whether prediction is accepted
            return
        }
        if doesAcceptPrediction(transaction: currentTransaction, prediction: prediction) {
            do {
                try predictionManager.savePrediction(prediction)
            } catch {
                // Failure in prediction should be resolved internally, as it is not known at all by the user
                log.warning("CoreLogic failed saving prediction")
            }
        }
    }

    private func doesAcceptPrediction(transaction: Transaction, prediction: Prediction) -> Bool {
        if transaction.amount == prediction.amountPredicted && transaction.tags == prediction.tagsPredicted {
            return true
        }
        return false
    }

    func deleteAllRecurringInstances(of transaction: Transaction) throws {
        guard transaction.frequency.nature == .recurring else {
            throw InvalidArgumentError(message: """
                deleteAllRecurringInstances() requires transaction to be recurring.
            """)
        }
        try transactionManager.deleteAllRecurringInstance(of: transaction)
    }

    func loadTransactions(month: Int, year: Int) throws -> [Transaction] {
        guard month > 0 && month < 13 else {
            throw InvalidArgumentError(message: "Month should be an integer ranging from 1 to 12.")
        }
        guard year >= 0 && year < 10_000 else {
            throw InvalidArgumentError(message: "Year should be an integer ranging from 0000 to 9999")
        }
        let monthString = String(format: "%02d", month)
        guard let startDate = Constants.getDateFormatter().date(from: "\(year)-\(monthString)-01 00:00:00") else {
            throw InitializationError(message: """
                Unable to initialize start date from month and year given in CoreLogic.loadTransaction().
            """)
        }
        guard let daysInMonth = Calendar.current.range(of: .day, in: .month, for: startDate)?.count else {
            throw InitializationError(message: """
                Unable to identify number of days in month supplied in CoreLogic.loadTransaction().
            """)
        }
        guard let endDate = Constants.getDateFormatter()
            .date(from: "\(year)-\(monthString)-\(daysInMonth) 23:59:59") else {
            throw InitializationError(message: """
                Unable to initialize end date from month and year given in CoreLogic.loadTransaction().
            """)
        }
        log.info("""
            CoreLogic.loadTransaction() with arguments:
            month=\(month) year=\(year).
            """)
        return try transactionManager.loadTransactions(from: startDate, to: endDate)
    }

    // MARK: Budget related
    func saveBudget(_ budget: Budget) throws {
        try budgetManager.saveBudget(budget)
    }

    func loadBudget() throws -> Budget {
        let budget = try budgetManager.loadBudget()
        let currentDate = Date()
        if budget.toDate < currentDate {
            // budget is overdue
            try budgetManager.deleteBudget()
            throw InitializationError(message: "Budget is outdated, needs to be reinitialized.")
        }
        return budget
    }

    func getSpendingStatus(_ currentMonthTransactions: [Transaction]) throws -> SpendingStatus {
        let budget = try self.loadBudget()
        var totalExpenditure: Decimal = 0.0
        for transaction in currentMonthTransactions where transaction.type == .expenditure {
            totalExpenditure += transaction.amount
        }
        return SpendingStatus(currentSpending: totalExpenditure, totalBudget: budget.amount)
    }

    // MARK: Tag related
    func getTag(for value: String, of parentValue: String?) throws -> Tag {
        return try tagManager.getTag(for: value, of: parentValue)
    }

    func getAllTags() -> [Tag: [Tag]] {
        return tagManager.tags
    }

    func getAllParentTags() -> [Tag] {
        return tagManager.parentTags
    }

    func getChildrenTags(of parent: String) throws -> [Tag] {
        return try tagManager.getChildrenTags(of: parent)
    }

    @discardableResult
    func addParentTag(_ name: String) throws -> Tag {
        return try tagManager.addParentTag(name)
    }

    @discardableResult
    func addChildTag(_ child: String, to parent: String) throws -> Tag {
        return try tagManager.addChildTag(child, to: parent)
    }

    @discardableResult
    func renameTag(for tag: Tag, to newValue: String) throws -> Tag {
        return try tagManager.renameTag(tag.value, to: newValue, of: tag.parentValue)
    }

    func removeChildTag(_ child: String, from parent: String) throws {
        let removedTags = try tagManager.removeChildTag(child, from: parent)
        for tags in removedTags {
            try transactionManager.deleteTagFromTransactions(tags)
        }
    }

    func removeParentTag(_ parent: String) throws {
        let removedTags = try tagManager.removeParentTag(parent)
        for tags in removedTags {
            try transactionManager.deleteTagFromTransactions(tags)
        }
    }

    // MARK: Prediction related
    func getPrediction(_ time: Date, _ location: CodableCLLocation,
                       _ transactions: [Transaction]) -> Prediction? {
        log.info("""
            CoreLogic.getPrediction() with arguments:
            time=\(time) location=\(location) transactions=\(transactions).
            """)
        return predictionManager.getPrediction(time, location, transactions)
    }
}
