//
//  StorageManagerInterface.swift
//  bacon
//
//  Created by Psychedelia on 17/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol StorageManagerInterface {
    // MARK: Transaction Related
    func getNumberOfTransactionsInDatabase() -> Double
    func clearTransactionDatabase() throws
    func saveTransaction(_ transaction: Transaction) throws
    func deleteTransaction(_ transaction: Transaction) throws
    func deleteAllRecurringInstances(of transaction: Transaction) throws
    func updateTransaction(_ transaction: Transaction) throws
    func loadAllTransactions() throws -> [Transaction]
    func loadTransactions(limit: Int) throws -> [Transaction]
    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction]
    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction]
    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction]
    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction]
    func loadTransactions(ofTag tag: Tag) throws -> [Transaction]
    func loadFirstRecurringInstance(of transaction: Transaction) throws -> Transaction

    // MARK: Budget Related
    func getNumberOfBudgetsInDatabase() -> Double
    func clearBudgetDatabase() throws
    func saveBudget(_ budget: Budget) throws
    func loadBudget() throws -> Budget
    func deleteTagFromTransactions(_ tag: Tag) throws

    // MARK: Prediction Related
    func getNumberOfPredictionsInDatabase() -> Double
    func clearPredictionDatabase() throws
    func savePrediction(_ prediction: Prediction) throws
    func loadAllPredictions() throws -> [Prediction]
    func loadPredictions(limit: Int) throws -> [Prediction]
}
