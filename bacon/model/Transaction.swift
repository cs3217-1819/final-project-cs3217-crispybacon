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
class Transaction: HashableClass, Codable, Observable {

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
        log.info("Initializing Transaction object.")

        self.date = date
        self.type = type
        self.frequency = frequency
        self.category = category
        self.amount = amount
        self.description = description
        self.image = image
        self.location = location

        super.init()
        do {
            try validate(date: date,
                         type: type,
                         frequency: frequency,
                         category: category,
                         amount: amount,
                         description: description,
                         image: image,
                         location: location)
        } catch let error as InvalidTransactionError {
            log.warning("Transaction initialization failed (InvalidTransactionError). Re-throwing as InitializationError.")
            throw InitializationError(message: error.message) // Propagate error as InitializationError
        }

        log.info("Transaction initialization succeeded.")
    }

    /// Edits one or more properties of a Transaction object.
    /// Pass in as many properties as should be edited.
    /// - Note: If properties are valid, observers of this Transaction object are notified automatically.
    ///     Otherwise, this Transaction object will not be mutated, and observers will not be notified.
    /// - Throws: `InvalidTransactionError` if at least 1 property is invalid.
    func edit(date: Date? = nil,
              type: TransactionType? = nil,
              frequency: TransactionFrequency? = nil,
              category: TransactionCategory? = nil,
              amount: Decimal? = nil,
              description: String? = nil,
              image: CodableUIImage? = nil,
              location: CodableCLLocation? = nil) throws {
        do {
            log.info("Editing Transaction instance.")
            try validate(date: date,
                         type: type,
                         frequency: frequency,
                         category: category,
                         amount: amount,
                         description: description,
                         image: image,
                         location: location)
        } catch let error as InvalidTransactionError {
            log.warning("Transaction editing failed (InvalidTransactionError. Rethrowing error.")
            throw error
        }

        // Update properties for those which are not nil

        if let date = date {
            self.date = date
        }
        if let type = type {
            self.type = type
        }
        if let frequency = frequency {
            self.frequency = frequency
        }
        if let category = category {
            self.category = category
        }
        if let amount = amount {
            self.amount = amount
        }
        if let description = description {
            self.description = description
        }
        if let image = image {
            self.image = image
        }
        if let location = location {
            self.location = location
        }

        log.info("Transaction editing succeeded.")
    }

    /// Notifies all observers of changes to self.
    /// This should be called after any mutation to a Transaction instance.
    private func notifyObserversOfSelf() {
        log.info("Notifying observers of new self.")
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

// MARK: Transaction validator
struct InvalidTransactionError: Error {
    let message: String
}

extension Transaction {

    /// Validates the properties of a Transaction object.
    /// Pass in as many properties as should be validated.
    /// - Throws: `InvalidTransactionError` if at least 1 property is invalid.
    private func validate(date: Date? = nil,
                          type: TransactionType? = nil,
                          frequency: TransactionFrequency? = nil,
                          category: TransactionCategory? = nil,
                          amount: Decimal? = nil,
                          description: String? = nil,
                          image: CodableUIImage? = nil,
                          location: CodableCLLocation? = nil) throws {
        log.info("Validating transaction properties.")

        /* Currently, we only validate `amount`.
         * This method should be extended as required in the future.
         * For each property to be checked, we first check that it is not nil,
         * since this method accepts transaction properties as optionals.
         */

        // Validation condition: amount should be > 0
        if (amount != nil && amount! <= 0) {
            log.warning("Amount=\(String(describing: amount)) is invalid. Throwing InvalidTransactionError.")
            throw InvalidTransactionError(message: "amount=\(amount!) must be > 0")
        }

        log.info("Transaction properties validation succeeded.")
    }

}

// MARK: Transaction: equals()
extension Transaction {

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
            && image?.image.pngData()?.base64EncodedString()
                == transaction.image?.image.pngData()?.base64EncodedString()
    }

}
