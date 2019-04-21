//
//  CoreLogic+BreakDownByLocation.swift
//  bacon
//
//  Created by Lizhi Zhang on 21/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

extension CoreLogic {
    func getBreakdownByLocation(from fromDate: Date, to toDate: Date) throws -> ([CLLocation]) {
        let transactions = try transactionManager.loadTransactions(from: fromDate, to: toDate)
        return try getBreakdownByLocation(transactions: transactions)
    }
    
    private func getBreakdownByLocation(transactions: [Transaction]) throws -> ([CLLocation]) {
        var locations = [CLLocation]()
        for transaction in transactions {
            if let location = transaction.location {
                locations.append(location.location)
            }
        }
        return locations
    }
}
