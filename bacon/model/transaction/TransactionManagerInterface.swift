//
//  TransactionManagerInterface.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 21/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol TransactionManagerInterface: Observer {

    func getNumberOfTransactionsInDatabase() -> Double
    func clearTransactionDatabase() throws
    func saveTransaction(_ transaction: Transaction) throws
    /// An edited recurring transaction should have its changes
    /// apply across all recurring instances.
    /// We disallow editing the date of a recurring transaction as
    /// users are able to edit a recurring transaction at an arbitrary instance of it,
    /// if we allow user to edit the date, we will be unable to back track and
    /// find out which instance the transaction was edited at.
    /// - requires: date of recurring transaction not modified
    func updateRecurringTransaction(_ transaction: Transaction) throws
    func deleteTagFromTransactions(_ tag: Tag) throws
    func deleteAllRecurringInstance(of transaction: Transaction) throws
    func loadTransactions(limit: Int) throws -> [Transaction]
    func loadTransactions(after date: Date, limit: Int) throws -> [Transaction]
    func loadTransactions(before date: Date, limit: Int) throws -> [Transaction]
    func loadTransactions(from fromDate: Date, to toDate: Date) throws -> [Transaction]
    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction]
    func loadTransactions(ofTag tag: Tag) throws -> [Transaction]
}
