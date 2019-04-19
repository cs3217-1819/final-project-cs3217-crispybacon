//
//  CoreLogic+BreakDownByTag.swift
//  bacon
//
//  Created by Lizhi Zhang on 12/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

extension CoreLogic {
    func getBreakdownByTag(from fromDate: Date, to toDate: Date, for tags: Set<Tag>) throws -> ([Tag], [Double]) {
        let transactions = try transactionManager.loadTransactions(from: fromDate, to: toDate)
        return try getBreakdownByTag(transactions: transactions, for: tags)
    }

    private func getBreakdownByTag(transactions: [Transaction], for tags: Set<Tag>) throws -> ([Tag], [Double]) {
        var tagAmount: [Tag: Double] = [:]

        // Initialize all required tags to have amount zero
        // This is important for the case where no transactions ever uses a particular tag
        for tag in tags {
            tagAmount[tag] = 0
        }

        // For each required tag, count the amount of transactions having this tag
        for transaction in transactions {
            for tag in transaction.tags where tags.contains(tag) {
                tagAmount[tag] = (tagAmount[tag] ?? 0) + NSDecimalNumber(decimal: transaction.amount).doubleValue
            }
        }

        // Put the dictionary into two arrays for use for the charting library
        var tags = [Tag](tagAmount.keys)
        var amounts = [Double]()
        for index in 0..<tags.count {
            guard let amountForThisTag = tagAmount[tags[index]] else {
                // It should have been initilaized to zero
                throw InitializationError(message: "Dictionary initializtion encountered error!")
            }
            amounts.append(amountForThisTag)
        }
        return (tags, amounts)
    }
}
