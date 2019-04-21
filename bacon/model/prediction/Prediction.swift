//
//  Prediction.swift
//  bacon
//
//  Created by Lizhi Zhang on 14/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Represents a prediction of a Transaction's details.
struct Prediction: Codable, Hashable {
    let time: Date
    let location: CodableCLLocation
    let amountPredicted: Decimal
    let tagsPredicted: Set<Tag>

    /// Instantiates a Prediction.
    /// - time: The predicted time.
    /// - location: The predicted location.
    /// - amount: The predicted amount. This must be greater than 0.
    /// - tags: The predicted tags.
    init(time: Date, location: CodableCLLocation, amount: Decimal, tags: Set<Tag>) throws {
        guard amount >= 0 else {
            throw InitializationError(message: "Amount must be of a non-negative value.")
        }
        self.time = time
        self.location = location
        self.amountPredicted = amount
        self.tagsPredicted = tags
    }
}

// MARK: Prediction: equals()
extension Prediction {
    /// Compares 2 predictions.
    /// - Returns: true if they have equal properties.
    func equals(_ prediction: Prediction) -> Bool {
        return time == prediction.time
            && location == prediction.location
            && amountPredicted == prediction.amountPredicted
            && tagsPredicted == prediction.tagsPredicted
    }
}
