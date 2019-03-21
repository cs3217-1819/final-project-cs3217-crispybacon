//
//  TransactionCategory.swift
//  bacon
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

enum TransactionCategory: String, Codable {
    case bills = "Bills"
    case education = "Education"
    case entertainment = "Entertainment"
    case food = "Food"
    case gift = "Gift"
    case salary = "Salary"
    case investment = "Investment"
    case loan = "Loan"
    case miscellaneous = "Miscellaneous"
    case personal = "Personal"
    case transport = "Transport"
    case travel = "Travel"
}
