//
//  Transaction.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Represents a mutable transaction.
class Transaction: Codable, Observable {

    private var _date: Date
    private var _type: TransactionType
    private var _frequency: TransactionFrequency
    private var _category: TransactionCategory
    private var _amount: Decimal
    private var _description: String

    var observers: [Observer] = []

    // See: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    // We exclude the "observers" property from being encoded/decoded,
    // since that information should not be persistent across sessions.
    private enum CodingKeys: String, CodingKey {
        case _date
        case _type
        case _frequency
        case _category
        case _amount
        case _description
    }

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

        _date = date
        _type = type
        _frequency = frequency
        _category = category
        _amount = amount
        _description = description
    }

    /// Notifies all observers of changes to self.
    /// This should be called after any mutation to a Transaction instance.
    private func notifyObserversOfSelf() {
        log.info("Notifying observers of new self")
        notifyObservers(self)
    }

    // Public computed properties
    var date: Date {
        get {
            return _date
        }

        set(newDate) {
            log.info("Setting date=\(newDate)")
            _date = newDate
            notifyObserversOfSelf()
        }
    }

    var type: TransactionType {
        get {
            return _type
        }

        set(newType) {
            log.info("Setting type=\(newType)")
            _type = newType
            notifyObserversOfSelf()
        }
    }

    var frequency: TransactionFrequency {
        get {
            return _frequency
        }

        set(newFrequency) {
            log.info("Setting frequency=\(newFrequency)")
            _frequency = newFrequency
            notifyObserversOfSelf()
        }
    }

    var category: TransactionCategory {
        get {
            return _category
        }

        set(newCategory) {
            log.info("Setting category=\(newCategory)")
            _category = newCategory
            notifyObserversOfSelf()
        }
    }

    var amount: Decimal {
        get {
            return _amount
        }

        set(newAmount) {
            log.info("Setting amount=\(newAmount)")
            _amount = newAmount
            notifyObserversOfSelf()
        }
    }

    var description: String {
        get {
            return _description
        }

        set(newDescription) {
            log.info("Setting description=\(newDescription)")
            _description = newDescription
            notifyObserversOfSelf()
        }
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
