//
//  Transaction.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct Transaction: Codable {
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

    /// Creates a Transaction instance from a Dictionary.
    init(dictionary: [String: Any]) throws {
        guard let date = dictionary["date"] as? Date else {
            throw InitializationError(message: "unable to read date from dictionary")
        }
        guard let type = dictionary["type"] as? TransactionType else {
            throw InitializationError(message: "unable to read type from dictionary")
        }
        guard let frequency = dictionary["frequency"] as? TransactionFrequency else {
            throw InitializationError(message: "unable to read frequency from dictionary")
        }
        guard let category = dictionary["category"] as? TransactionCategory else {
            throw InitializationError(message: "unable to read category from dictionary")
        }
        guard let amount = dictionary["amount"] as? Decimal else {
            throw InitializationError(message: "unable to read amount from dictionary")
        }
        guard amount > 0 else {
            throw InitializationError(message: "`amount` must be greater than 0")
        }
        guard let description = dictionary["description"] as? String else {
            throw InitializationError(message: "unable to read description from dictionary")
        }

        self.date = date
        self.type = type
        self.frequency = frequency
        self.category = category
        self.amount = amount
        self.description = description
    }
}
