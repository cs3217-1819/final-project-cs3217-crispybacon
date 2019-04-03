//
//  Transaction.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

// MARK: Transaction class
/// Represents a mutable transaction.
class Transaction: Codable, Observable {

    var date: Date {
        didSet {
            log.info("Set date=\(date)")
            notifyObserversOfSelf()
        }
    }
    var type: TransactionType {
        didSet {
            log.info("Set type=\(type)")
            notifyObserversOfSelf()
        }
    }
    var frequency: TransactionFrequency {
        didSet {
            log.info("Set frequency=\(frequency)")
            notifyObserversOfSelf()
        }
    }
    var category: TransactionCategory {
        didSet {
            log.info("Set category=\(category)")
            notifyObserversOfSelf()
        }
    }
    var amount: Decimal {
        didSet {
            log.info("Set amount=\(amount)")
            notifyObserversOfSelf()
        }
    }
    var description: String {
        didSet {
            log.info("Set description=\(description)")
            notifyObserversOfSelf()
        }
    }
    var image: CodableUIImage? {
        didSet {
            log.info("Updated image")
            notifyObserversOfSelf()
        }
    }
    var location: CodableCLLocation? {
        didSet {
            log.info("Set location=\(String(describing: location))")
            notifyObserversOfSelf()
        }
    }

    var observers: [Observer] = []

    // See: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    // We exclude the "observers" property from being encoded/decoded,
    // since that information should not be persistent across sessions.
    private enum CodingKeys: String, CodingKey {
        case date
        case type
        case frequency
        case category
        case amount
        case description
        case image
        case location
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
         description: String = "",
         image: CodableUIImage? = nil,
         location: CodableCLLocation? = nil) throws {
        log.info("""
            Transaction:init() with the following arguments:
            date=\(date) type=\(type) frequency=\(frequency) category=\(category)
            amount=\(amount) description=\(description) location=\(String(describing: location))
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
        self.image = image
        self.location = location
    }

    /// Notifies all observers of changes to self.
    /// This should be called after any mutation to a Transaction instance.
    private func notifyObserversOfSelf() {
        log.info("Notifying observers of new self")
        notifyObservers(self)
    }

}

// MARK: Transaction: Equatable
extension Transaction: Equatable {

    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.date == rhs.date
            && lhs.type == rhs.type
            && lhs.frequency == rhs.frequency
            && lhs.category == rhs.category
            && lhs.amount == rhs.amount
            && lhs.description == rhs.description
            && lhs.image == rhs.image
            && lhs.location == rhs.location
    }

    static func != (lhs: Transaction, rhs: Transaction) -> Bool {
        return !(lhs == rhs)
    }

}

// MARK: Transaction: Hashable
extension Transaction: Hashable {

    // See: https://developer.apple.com/documentation/swift/hashable/2995575-hash
    // See also: https://developer.apple.com/documentation/swift/hashable/1540917-hashvalue where
    //      Apple states that hashValue is deprecated as a Hashable requirement,
    //      and to use func hash(into:) instead.
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(type)
        hasher.combine(frequency)
        hasher.combine(category)
        hasher.combine(amount)
        hasher.combine(description)
        hasher.combine(image)
        hasher.combine(location)
    }

}

