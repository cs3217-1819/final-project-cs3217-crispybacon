//
//  Decimal+toFormattedString.swift
//  bacon
//
//  Created by Lizhi Zhang on 3/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

extension Decimal {
    var toFormattedString: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        return formatter.string(from: self as NSDecimalNumber)
    }
}
