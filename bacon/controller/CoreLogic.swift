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
    let transactionManager: TransactionManager
    let budgetManager: BudgetManager
    let predictionManager: PredictionManager
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
                           location: CodableCLLocation? = nil) throws {
        let currentTransaction = try Transaction(date: date, type: type, frequency: frequency,
                                                 tags: tags, amount: amount, description: description,
                                                 image: image, location: location)
        log.info("""
            CoreLogic.recordTransaction() with arguments:
            date=\(date) type=\(type) frequency=\(frequency) tags=\(tags) amount=\(amount)
            description=\(description) location=\(location as Optional).
            """)
        try transactionManager.saveTransaction(currentTransaction)
        if currentTransaction.frequency.nature == .recurring {
            try recordRecurringTransaction(currentTransaction)
        }
    }

    // Save future recurring instances of the transaction given.
    private func recordRecurringTransaction(_ transaction: Transaction) throws {
        guard transaction.frequency.nature == .recurring else {
            throw InvalidArgumentError(message: """
                recordRecurringTransaction() requires transaction to be recurring.
            """)
        }
        let recurringInstances = try generateAllRecurringInstances(of: transaction)
        for transactions in recurringInstances {
            // Save the next recurring transaction
            try transactionManager.saveTransaction(transactions)
        }
    }

    /// Generates all subsequent future recurring instances of a transaction
    /// (i.e. the first instance of a recurring transaction is not included)
    private func generateAllRecurringInstances(of transaction: Transaction) throws -> [Transaction] {
        guard transaction.frequency.nature == .recurring else {
            throw InvalidArgumentError(message: """
                generateAllRecurringInstances() requires transaction to be recurring.
            """)
        }
        guard let numberOfTimesToRepeat = transaction.frequency.repeats else {
            fatalError("Transaction is guarded to be recurring, repeats should not be nil.")
        }
        guard let interval = transaction.frequency.interval else {
            fatalError("Transaction is guarded to be recurring, interval should not be nil.")
        }
        var currentTime = transaction.date
        var dateComponents = DateComponents()
        switch interval {
        case .daily:
            dateComponents.day = 1
        case .weekly:
            dateComponents.day = 7
        case .monthly:
            dateComponents.month = 1
        case .yearly:
            dateComponents.year = 1
        }
        var recurringTransactions: [Transaction] = []
        for _ in 1..<numberOfTimesToRepeat {
            // Calculate the date of the next recurring transaction
            guard let nextRecurringDate = Calendar.current.date(byAdding: dateComponents,
                                                                to: currentTime) else {
                fatalError("Date calculation for future recurring transaction should not fail.")
            }
            currentTime = nextRecurringDate
            // Create a copy of the transaction and update the date
            let nextTransaction = transaction.duplicate()
            try nextTransaction.edit(date: currentTime)
            recurringTransactions.append(nextTransaction)
        }
        return recurringTransactions
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
        return try budgetManager.loadBudget()
    }

    func getSpendingStatus(_ currentMonthTransactions: [Transaction]) throws -> SpendingStatus {
        let budget = try budgetManager.loadBudget()
        var totalExpenditure: Decimal = 0.0
        for transaction in currentMonthTransactions where transaction.type == .expenditure {
            totalExpenditure += transaction.amount
        }
        return SpendingStatus(currentSpending: totalExpenditure, totalBudget: budget.amount)
    }

    // MARK: Tag related
    func getAllTags() -> [Tag: [Tag]] {
        return tagManager.tags
    }

    func getAllParentTags() -> [Tag] {
        return tagManager.parentTags
    }

    func addParentTag(_ name: String) throws -> Tag {
        return try tagManager.addParentTag(name)
    }

    func addChildTag(_ child: String, to parent: String) throws -> Tag {
        return try tagManager.addChildTag(child, to: parent)
    }

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
