//
//  Date+getStartOrEndOfMonth.swift
//  bacon
//
//  Created by Lizhi Zhang on 20/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

extension Date {
    func getStartOfCurrentMonth() throws -> Date {
        guard let date = Calendar.current.date(from:
            Calendar.current.dateComponents([.year, .month],
                                            from: Calendar.current.startOfDay(for: self))) else {
                                                throw InitializationError(message:
                                                    "Should be able to retrieve the start of month.")
        }
        return date
    }

    func getEndOfCurrentMonth() throws -> Date {
        guard let date = Calendar.current.date(byAdding: DateComponents(month: 1,
                                                                        second: -1),
                                               to: try self.getStartOfCurrentMonth()) else {
                                                throw InitializationError(message:
                                                    "Should be able to retrieve the end of month.")
        }
        return date
    }
}
