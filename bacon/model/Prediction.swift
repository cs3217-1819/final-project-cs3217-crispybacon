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
    let amountPredicred: Decimal
    let tagsPredicted: Set<Tag>

    init(time: Date, location: CodableCLLocation, transactions: [Transaction],
         amount: Decimal, tags: Set<Tag>) {
        self.time = time
        self.location = location
        self.pastTransactions = transactions
        self.amountPredicred = amount
        self.tagsPredicted = tags
    }
}
