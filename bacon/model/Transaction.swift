//
//  Transaction.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct Transaction {
    let date: Date
    let type: TransactionType
    let frequency: TransactionFrequency
    let category: TransactionCategory
    let amount: Decimal
    let description: String

    /// Creates a Transaction instance.
    /// - Parameters:
    ///     - date: The transaction date.
    ///     - type: The transaction type.
    ///     - frequency: The transaction frequency.
    ///     - category: The transaction category.
    ///     - amount: The transaction amount. Must be > 0.
    ///     - description: An optional description of the transaction. Defaults to an empty string.
    /// - Throws: `InitializationError` if `amount <= 0`.
    init(date: Date,
         type: TransactionType,
         frequency: TransactionFrequency,
         category: TransactionCategory,
         amount: Decimal,
         description: String = "") throws {
        guard amount > 0 else {
            throw InitializationError(message: "`amount` must be greater than 0")
        }

        self.date = date
        self.type = type
        self.frequency = frequency
        self.category = category
        self.amount = amount
        self.description = description
    }
}
