//
//  Budget.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 8/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct Budget: Codable, Equatable {
    let fromDate: Date
    let toDate: Date
    let amount: Decimal

    init (from fromDate: Date, to toDate: Date, amount: Decimal) throws {
        guard fromDate < toDate else {
            throw InitializationError(message: "'from' date must not be equivalent or later than 'to' date.")
        }
        guard amount >= 0 else {
            throw InitializationError(message: "Budget must be of a non-negative value.")
        }
        self.fromDate = fromDate
        self.toDate = toDate
        self.amount = amount
    }
}
