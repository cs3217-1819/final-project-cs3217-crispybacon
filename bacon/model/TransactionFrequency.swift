//
//  TransactionFrequency.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

enum TransactionFrequencyNature: String, Codable, Equatable {
    case oneTime
    case recurring
}

enum TransactionFrequencyInterval: String, Codable, Equatable {
    case daily
    case weekly
    case monthly
    case yearly
}

struct TransactionFrequency: Codable, Equatable {
    let nature: TransactionFrequencyNature
    let interval: TransactionFrequencyInterval?
    let repeats: Int?

    /// Creates a TransactionFrequency instance.
    /// - Parameters:
    ///     - nature: The nature of the transaction frequency.
    ///     - interval: The recurring interval of a recurring transaction.
    ///     - repeats: The number of times a recurring transaction is to be repeated for (e.g. 2 repeats create 3 transactions).
    ///         If `repeats` is provided, it must be >= 1.
    /// - Note: `interval` and `repeats` will be set to `nil` if `nature == .oneTime`, and any provided arguments are ignored.
    /// - Throws: `InitializationError` if invalid arguments are provided.
    init(nature: TransactionFrequencyNature, interval: TransactionFrequencyInterval?, repeats: Int?) throws {
        log.info("""
            TransactionFrequency:init() using the designated initializer with the following arguments:
            nature=\(nature) interval=\(String(describing: interval)) repeats=\(String(describing: repeats))
            """)

        self.nature = nature

        switch nature {
        case .oneTime:
            log.debug("nature == .oneTime")

            self.interval = nil
            self.repeats = nil

        case .recurring:
            log.debug("nature == .recurring")

            guard let interval = interval else {
                log.info("interval == nil. Throwing InitializationError.")
                throw InitializationError(message: "`interval` must be provided")
            }
            guard let repeats = repeats else {
                log.info("repeats == nil. Throwing InitializationError.")
                throw InitializationError(message: "`repeats` must be provided")
            }
            guard repeats >= 1 else {
                log.info("repeats <= 0. Throwing InitializationError.")
                throw InitializationError(message: "`repeats` must be at least 1")
            }

            self.interval = interval
            self.repeats = repeats
        }
    }

    /// Convenience initializer for one time transactions.
    /// This is equivalent to `init(nature: nature, interval: nil, repeats: nil`.
    /// Therefore, this will fail is `nature != .oneTime`.
    init(nature: TransactionFrequencyNature) throws {
        log.info("TransactionFrequency:init() using the convenience initializer")
        try self.init(nature: nature, interval: nil, repeats: nil)
    }
}
