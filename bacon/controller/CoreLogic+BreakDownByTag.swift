//
//  CoreLogic+BreakDownByTag.swift
//  bacon
//
//  Created by Lizhi Zhang on 12/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

extension CoreLogic {
    func getBreakdownByTag(from fromDate: Date, to toDate: Date, for tags: Set<Tag>) throws -> [Tag: Int] {
        let transactions = try transactionManager.loadTransactions(from: fromDate, to: toDate)
        return getBreakdownByTag(transactions: transactions, for: tags)
    }

    private func getBreakdownByTag(transactions: [Transaction], for tags: Set<Tag>) -> [Tag: Int] {
        var tagCount: [Tag: Int] = [:]
        transactions.forEach { transaction in
            tagCount[transaction.category] = (tagCount[transaction.category] ?? 0) + 1
        }
        return tagCount
    }
}
