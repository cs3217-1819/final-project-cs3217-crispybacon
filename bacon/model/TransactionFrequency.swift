//
//  TransactionFrequency.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

enum TransactionFrequencyNature {
    case oneTime
    case recurring
}

enum TransactionFrequencyInterval {
    case daily
    case weekly
    case monthly
    case yearly
}

struct TransactionFrequency: Equatable {
    let nature: TransactionFrequencyNature
    let interval: TransactionFrequencyInterval?
    let repeats: Int?

    /// Creates a TransactionFrequency instance.
    /// `interval` and `repeats` may be omitted only if `nature == .oneTime` (if they are specified, they will be ignored).
    /// - Parameters:
    ///     - nature: The nature of the transaction frequency.
    ///     - interval: The recurring interval of a recurring transaction.
    ///     - repeats: The number of times a recurring transaction is to be repeated for (e.g. 2 repeats create 3 transactions).
    ///         If `repeats` is provided, it must be >= 1.
    /// - Throws: `InitializationError` if `nature == .recurring` and either `interval` or `repeats` is not provided,
    ///     or if an invalid `repeats` value is provided.
    init(nature: TransactionFrequencyNature, interval: TransactionFrequencyInterval? = nil, repeats: Int? = nil) throws {
        self.nature = nature

        switch nature {
        case .oneTime:
            self.interval = nil
            self.repeats = nil
        case .recurring:
            guard let interval = interval else {
                throw InitializationError(message: "`interval` must be provided")
            }
            guard let repeats = repeats else {
                throw InitializationError(message: "`repeats` must be provided")
            }
            guard repeats >= 1 else {
                throw InitializationError(message: "`repeats` must be at least 1")
            }

            self.interval = interval
            self.repeats = repeats
        }
    }
}
