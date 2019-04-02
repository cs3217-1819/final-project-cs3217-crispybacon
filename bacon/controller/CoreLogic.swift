//
//  CoreLogic.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 2/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class CoreLogic {
    init() {

    }

    func recordTransaction(date: Date, type: TransactionType, frequency: TransactionFrequency,
                           category: TransactionCategory, amount: Decimal, description: String,
                           location: CodableCLLocation? = nil ) throws {
        let currentTransaction = try Transaction(date: date, type: type, frequency: frequency,
                                                 category: category, amount: amount, description: description,
                                                 location: location)
        log.info("""
            CoreLogic.recordTransaction() with arguments:
            date=\(date) type=\(type) frequency=\(frequency) category=\(category) amount=\(amount)
            description=\(description) location=\(location as Optional).
            """)
        guard let storageManager = StorageManager.sharedStorage else {
            throw StorageError(message: "Encounter error accessing storage manager instance in CoreLogic.")
        }
        try storageManager.saveTransaction(currentTransaction)
    }
}
