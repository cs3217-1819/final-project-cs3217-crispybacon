//
//  StorageManager.swift
//  bacon
//
//  An API for all storage related functionalities.
//  Provides an abstraction over the underlying storage library dependacies.
//
//  Created by Travis Ching Jia Yea on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class StorageManager {
    private var concreteStorage: StorageCouchBaseDB

    init() throws {
        concreteStorage = try StorageCouchBaseDB()
    }

    func saveTransaction(_ transaction: Transaction) throws {
        try concreteStorage.saveTransaction(transaction)
    }

    func loadTransactions(ofType type: TransactionType, limit: Int) throws -> [Transaction] {
        return try concreteStorage.loadTransactions(ofType: type, limit: limit)
    }

    func clearTransactionDatabase() throws {
        return try concreteStorage.clearTransactionDatabase()
    }
}
