//
//  Budget.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 8/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct Budget: Codable {
    let from: Date
    let to: Date
    let amount: Decimal

    init (from: Date, to: Date, amount: Decimal) throws {
        guard from < to else {
            throw InitializationError(message: "'from' date must not be equivalent or later than 'to' date.")
        }
        guard amount >= 0 else {
            throw InitializationError(message: "Budget must be of a non-negative value.")
        }
        self.from = from
        self.to = to
        self.amount = amount
    }
}
