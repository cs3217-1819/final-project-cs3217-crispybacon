//
//  Prediction.swift
//  bacon
//
//  Created by Lizhi Zhang on 14/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct Prediction: Codable, Hashable {
    let time: Date
    let location: CodableCLLocation
    let pastTransactions: [Transaction]
    let amountPredicted: Decimal
    let tagsPredicted: Set<Tag>

    init(time: Date, location: CodableCLLocation, transactions: [Transaction],
         amount: Decimal, tags: Set<Tag>) throws {
        guard amount >= 0 else {
            throw InitializationError(message: "Amount must be of a non-negative value.")
        }
        self.time = time
        self.location = location
        self.pastTransactions = transactions
        self.amountPredicted = amount
        self.tagsPredicted = tags
    }
}

// MARK: Prediction: equals()
extension Prediction {
    /// Compares 2 predictions.
    /// - Returns: true if they have equal properties.
    func equals(_ prediction: Prediction) -> Bool {
        var hasEqualPastTransactions = true
        for (index, transaction) in pastTransactions.enumerated() {
            if !transaction.equals(prediction.pastTransactions[index]) {
                hasEqualPastTransactions = false
                break
            }
        }
        return time == prediction.time
            && location == prediction.location
            && amountPredicted == prediction.amountPredicted
            && tagsPredicted == prediction.tagsPredicted
            && hasEqualPastTransactions
    }
}
