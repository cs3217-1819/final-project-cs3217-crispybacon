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
        return currentSpending / totalBudget
    }
}
