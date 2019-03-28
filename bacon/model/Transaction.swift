//
//  Transaction.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class Transaction: Codable {

    var date: Date
    var type: TransactionType
    var frequency: TransactionFrequency
    var category: TransactionCategory
    var amount: Decimal
    var description: String

    /// Creates a Transaction instance.
    /// - Parameters:
    ///     - time: The transaction time, as represented by a TransactionTime object.
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
        log.info("""
            Transaction:init() with the following arguments:
            date=\(date) type=\(type) frequency=\(frequency) category=\(category)
            amount=\(amount) description=\(description)
            """)

        guard amount > 0 else {
            log.info("amount <= 0. Throwing InitializationError.")
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

extension Transaction: Equatable {

    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.date == rhs.date
            && lhs.type == rhs.type
            && lhs.frequency == rhs.frequency
            && lhs.category == rhs.category
            && lhs.amount == rhs.amount
            && lhs.description == rhs.description
    }

}
