//
//  CoreLogic+BreakDownByTime.swift
//  bacon
//
//  Created by Lizhi Zhang on 20/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

extension CoreLogic {
    func getBreakdownByTime(from fromDate: Date, to toDate: Date) throws -> ([(Int, Int)], [Double]) {
        let months = try calculateMonthsIncluded(from: fromDate, to: toDate)
        var amounts = [Double]()
        for index in 0..<months.count {
            amounts.append(try calculateMonthlyNetIncome(month: months[index].0, year: months[index].1))
        }
        return (months, amounts)
    }

    private func calculateMonthsIncluded(from fromDate: Date, to toDate: Date) throws -> [(Int, Int)] {
        let calendar = Calendar.current
        var referenceDate = fromDate
        var monthsIncluded = [(Int, Int)]()
        var dateComponents = DateComponents()
        dateComponents.month = 1

        while referenceDate <= toDate {
            let year = calendar.component(.year, from: referenceDate)
            let month = calendar.component(.month, from: referenceDate)
            monthsIncluded.append((month, year))
            guard let nextMonth = Calendar.current.date(byAdding: dateComponents, to: referenceDate) else {
                throw InitializationError(message: "Date initializtion encountered error!")
            }
            referenceDate = nextMonth
        }

        return monthsIncluded
    }

    private func calculateMonthlyNetIncome(month: Int, year: Int) throws -> Double {
        let currentMonthTransactiosn = try self.loadTransactions(month: month, year: year)
        var total: Double = 0
        for transaction in currentMonthTransactiosn {
            if transaction.type == .expenditure {
                total -= NSDecimalNumber(decimal: transaction.amount).doubleValue
            } else {
                total += NSDecimalNumber(decimal: transaction.amount).doubleValue
            }
        }
        return total
    }
}
