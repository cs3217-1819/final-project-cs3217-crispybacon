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

    private func getBreakdownByTag(transactions: [Transaction],
                                   for requiredTags: Set<Tag>) throws -> ([Tag], [Double]) {
        var tagAmount: [Tag: Double] = [:]

        // Initialize all required tags to have amount zero
        // This is important for the case where no transactions ever uses a particular tag
        for tag in requiredTags {
            tagAmount[tag] = 0
        }

        // For each required tag, count the amount of transactions having this tag
        for transaction in transactions {
            for tag in transaction.tags where requiredTags.contains(tag) {
                // Firstly, if the transaction contains a tag that is required, increase the amount for the tag
                tagAmount[tag] = (tagAmount[tag] ?? 0) + NSDecimalNumber(decimal: transaction.amount).doubleValue

                // If the current tag is a child tag, this transaction must be counted towards the parent tag too
                // Provided the transaction is not tagged with the parent tag itself (to prevent double counting)
                if let parentTagValue = tag.parentValue {
                    let parentTag = try self.getTag(for: parentTagValue, of: nil) // We know it's a parent tag
                    if requiredTags.contains(parentTag) && !transaction.tags.contains(parentTag) {
                        tagAmount[parentTag] = (tagAmount[parentTag] ?? 0) +
                            NSDecimalNumber(decimal: transaction.amount).doubleValue
                    }
                }
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
