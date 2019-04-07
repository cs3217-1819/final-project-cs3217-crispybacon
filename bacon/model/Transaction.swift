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

    // Support transaction deletion through the delete() method.
    // These variables should be externally readable but not settable.
    private(set) var isDeleted = false
    private(set) var deleteSuccessCallback: () -> Void = {}
    private(set) var deleteFailureCallback: (String) -> Void = { _ in }

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

    /// Deletes this transaction. Accepts 2 optional parameters.
    /// - Parameters:
    ///     - successCallback: Will be called when the transaction is successfully deleted.
    ///     - failureCallback: Will be called with an error message if an error occurs
    ///                        while attempting to delete the transaction.
    func delete(successCallback: @escaping () -> Void = {},
                failureCallback: @escaping (String) -> Void = { _ in }) {
        isDeleted = true
        deleteSuccessCallback = successCallback
        deleteFailureCallback = failureCallback
        notifyObserversOfSelf()
    }

}

// MARK: Transaction: Equatable
extension Transaction: Equatable {

    /// Compares 2 transactions.
    /// - Returns: true if they have equal properties.
    func equals(_ transaction: Transaction) -> Bool {
        return date == transaction.date
            && type == transaction.type
            && frequency == transaction.frequency
            && category == transaction.category
            && amount == transaction.amount
            && description == transaction.description
            && location == transaction.location
            && image?.image.pngData()?.base64EncodedString() == transaction.image?.image.pngData()?.base64EncodedString()
    }

    // We check for identity so we don't end up with a situation where
    // transaction1 == transaction2 but transaction1 has a different hash value from transaction2.
    // For comparison of transaction properties, use .equals() instead.
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs === rhs
    }

}

// MARK: Transaction: Hashable
extension Transaction: Hashable {

    // We use ObjectIdentifier(self) so 2 distinct but equivalent transactions hash to different values.
    // This lets us map distinct Transaction objects to arbitrary values, even if some may be equivalent.
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

}
