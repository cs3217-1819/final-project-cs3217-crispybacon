//
//  Transaction.swift
//  bacon
//
//  Represents a mutable transaction.
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

// MARK: Transaction class
class Transaction: HashableClass, Codable, Observable {

    // Support transaction deletion through the delete() method.
    // These variables should be externally readable but not settable.
    private(set) var isDeleted = false
    private(set) var deleteSuccessCallback: () -> Void = {}
    private(set) var deleteFailureCallback: (String) -> Void = { _ in }
    private(set) var editSuccessCallback: () -> Void = {}
    private(set) var editFailureCallback: (String) -> Void = { _ in }

    private(set) var date: Date {
        didSet {
            log.info("Set date=\(date)")
            //notifyObserversOfSelf()
        }
    }
    private(set) var type: TransactionType {
        didSet {
            log.info("Set type=\(type)")
            //notifyObserversOfSelf()
        }
    }
    private(set) var frequency: TransactionFrequency {
        didSet {
            log.info("Set frequency=\(frequency)")
            //notifyObserversOfSelf()
        }
    }
    private(set) var tags: Set<Tag> {
        didSet {
            log.info("Set tags=\(tags)")
            //notifyObserversOfSelf()
        }
    }
    private(set) var amount: Decimal {
        didSet {
            log.info("Set amount=\(amount)")
            //notifyObserversOfSelf()
        }
    }
    private(set) var description: String {
        didSet {
            log.info("Set description=\(description)")
            //notifyObserversOfSelf()
        }
    }
    private(set) var image: CodableUIImage? {
        didSet {
            log.info("Updated image")
            //notifyObserversOfSelf()
        }
    }
    private(set) var location: CodableCLLocation? {
        didSet {
            log.info("Set location=\(String(describing: location))")
            //notifyObserversOfSelf()
        }
    }
    private(set) var recurringId: UUID?

    var observers: [Observer] = []

    // See: https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
    // We exclude the "observers" property from being encoded/decoded,
    // since that information should not be persistent across sessions.
    private enum CodingKeys: String, CodingKey {
        case date
        case type
        case frequency
        case tags
        case amount
        case description
        case image
        case location
        case recurringId
    }

    /// Creates a Transaction instance.
    /// - Parameters:
    ///     - date: The transaction date, as represented by a Date object.
    ///     - type: The transaction type.
    ///     - frequency: The transaction frequency.
    ///     - tags: The transaction tags.
    ///     - amount: The transaction amount. Must be > 0.
    ///     - description: An optional description of the transaction. Defaults to an empty string.
    /// - Throws: `InitializationError` if `amount <= 0`.
    init(date: Date,
         type: TransactionType,
         frequency: TransactionFrequency,
         tags: Set<Tag>,
         amount: Decimal,
         description: String = "",
         image: CodableUIImage? = nil,
         location: CodableCLLocation? = nil) throws {
        log.info("Initializing Transaction object.")

        self.date = date
        self.type = type
        self.frequency = frequency
        self.tags = tags
        self.amount = amount
        self.description = description
        self.image = image
        self.location = location
        // If its a recurring transaction, generate a recurring id
        if frequency.nature == .recurring {
            self.recurringId = UUID()
        }
        super.init()
        do {
            try validate(date: date,
                         type: type,
                         frequency: frequency,
                         tags: tags,
                         amount: amount,
                         description: description,
                         image: image,
                         location: location)
        } catch let error as InvalidTransactionError {
            log.warning("""
                Transaction initialization failed (InvalidTransactionError).
                Re-throwing as InitializationError.
                """)
            throw InitializationError(message: error.message) // Propagate error as InitializationError
        }

        log.info("Transaction initialization succeeded.")
    }

    private init(date: Date,
                 type: TransactionType,
                 frequency: TransactionFrequency,
                 tags: Set<Tag>,
                 amount: Decimal,
                 description: String = "",
                 image: CodableUIImage? = nil,
                 location: CodableCLLocation? = nil,
                 recurringId: UUID? = nil) throws {
        log.info("Initializing Transaction object with private init.")

        self.date = date
        self.type = type
        self.frequency = frequency
        self.tags = tags
        self.amount = amount
        self.description = description
        self.image = image
        self.location = location
        self.recurringId = recurringId

        super.init()
        do {
            try validate(date: date,
                         type: type,
                         frequency: frequency,
                         tags: tags,
                         amount: amount,
                         description: description,
                         image: image,
                         location: location)
        } catch let error as InvalidTransactionError {
            log.warning("""
                Transaction initialization failed (InvalidTransactionError).
                Re-throwing as InitializationError.
                """)
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
              tags: Set<Tag>? = nil,
              amount: Decimal? = nil,
              description: String? = nil,
              image: CodableUIImage? = nil,
              location: CodableCLLocation? = nil,
              successCallback: @escaping () -> Void = {},
              failureCallback: @escaping (String) -> Void = { _ in }) throws {
        do {
            log.info("Editing Transaction instance.")
            editSuccessCallback = successCallback
            editFailureCallback = failureCallback
            try validate(date: date,
                         type: type,
                         frequency: frequency,
                         tags: tags,
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
        if let tags = tags {
            self.tags = tags
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
        notifyObserversOfSelf()
        log.info("Transaction editing succeeded.")
    }

    /// Notifies all observers of changes to self.
    /// This should be called after any mutation to a Transaction instance.
    private func notifyObserversOfSelf() {
        log.info("Notifying observers of new self.")
        notifyObservers(self)
    }

    /// Deletes this transaction. Accepts 2 parameters with default values.
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
                          tags: Set<Tag>? = nil,
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
        // swiftlint:disable force_unwrapping
        if amount != nil && amount! <= 0 {
            log.warning("Amount=\(String(describing: amount)) is invalid. Throwing InvalidTransactionError.")
            throw InvalidTransactionError(message: "amount=\(amount!) must be > 0")
        }
        // swiftlint:enable force_unwrapping

        log.info("Transaction properties validation succeeded.")
    }

}

// MARK: Transaction: duplicate()
extension Transaction {
    /// Create a copy of the Transaction with the exact same values
    func duplicate() -> Transaction {
        guard let transactionCopy = try? Transaction(date: date,
                                                     type: type,
                                                     frequency: frequency,
                                                     tags: tags,
                                                     amount: amount,
                                                     description: description,
                                                     image: image,
                                                     location: location,
                                                     recurringId: recurringId) else {
            // A copy is created from a valid instance, this should never throw.
            fatalError("Failed to duplicate valid Transaction.")
        }
        return transactionCopy
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
            && tags == transaction.tags
            && amount == transaction.amount
            && description == transaction.description
            && location == transaction.location
            && image?.image.pngData()?.base64EncodedString()
                == transaction.image?.image.pngData()?.base64EncodedString()
            && recurringId == transaction.recurringId
    }
}
