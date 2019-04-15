//
//  SpendingStatus.swift
//  bacon
//
//  Created by Lizhi Zhang on 13/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct SpendingStatus {
    let currentSpending: Decimal
    let totalBudget: Decimal
    var percentage: Decimal {
        if totalBudget == 0 {
            if currentSpending == 0 {
                return 1
            } else {
                return 100
            }
        }
        return currentSpending / totalBudget
    }
}
