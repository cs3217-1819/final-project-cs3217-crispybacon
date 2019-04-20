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
        let adjustedDates = try adjustFromAndToDates(fromDate: fromDate, toDate: toDate)
        let months = try calculateMonthsIncluded(from: fromDate, to: toDate)
        var amounts = [Double]()
        for index in 0..<months.count {
            amounts.append(try calculateMonthlyNetIncome(month: months[index].0, year: months[index].1,
                                                         fromDate: adjustedDates.0, toDate: adjustedDates.1))
        }
        return (months, amounts)
    }

    // Set the fromDate to its first moment (00:00:00) and the toDate to its last moment (23:59:00)
    private func adjustFromAndToDates(fromDate: Date, toDate: Date) throws -> (Date, Date) {
        let calendar = Calendar.current
        let fromDateStart = calendar.startOfDay(for: fromDate)
        guard let toDateEnd = calendar.date(byAdding: DateComponents(day: 1, second: -1),
                                            to: calendar.startOfDay(for: toDate)) else {
                                                throw InitializationError(message:
                                                    "Date initializtion encountered error!")
        }
        return (fromDateStart, toDateEnd)
    }

    private func calculateMonthsIncluded(from fromDate: Date, to toDate: Date) throws -> [(Int, Int)] {
        let calendar = Calendar.current
        var monthsIncluded = [(Int, Int)]()
        var dateComponents = DateComponents()
        dateComponents.month = 1 // Each time we add one month to the date

        var referenceDate = fromDate // A Date object to help roll over the dates

        // Adjust the toDate to the first day of the next month after the given toDate
        // e.g. If toDate is 21/04/2019, then toDateAdjusted will be 01/05/2019
        // So as to ensure the loop below always includes the month of the toDate
        guard let oneMonthAfterToDate = calendar.date(byAdding: dateComponents, to: toDate) else {
            throw InitializationError(message: "Date initializtion encountered error!")
        }
        let toDateAdjusted = try oneMonthAfterToDate.getStartOfCurrentMonth()

        while referenceDate < toDateAdjusted {
            let year = calendar.component(.year, from: referenceDate)
            let month = calendar.component(.month, from: referenceDate)
            monthsIncluded.append((month, year))
            guard let nextMonth = calendar.date(byAdding: dateComponents, to: referenceDate) else {
                throw InitializationError(message: "Date initializtion encountered error!")
            }
            referenceDate = nextMonth
        }

        return monthsIncluded
    }

    private func calculateMonthlyNetIncome(month: Int, year: Int, fromDate: Date, toDate: Date) throws -> Double {
        let currentMonthTransactions = try self.loadTransactions(month: month, year: year)
        var total: Double = 0
        for transaction in currentMonthTransactions where transaction.date <= toDate && transaction.date >= fromDate {
            if transaction.type == .expenditure {
                total -= NSDecimalNumber(decimal: transaction.amount).doubleValue
            } else {
                total += NSDecimalNumber(decimal: transaction.amount).doubleValue
            }
        }
        return total
    }
}
