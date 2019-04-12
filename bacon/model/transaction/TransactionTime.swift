//
//  TransactionTime.swift
//  bacon
//
//  Created by Fabian Terh on 26/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

struct TransactionTime: Codable, Equatable {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    let second: Int

    init(_ date: Date) {
        let calendar = Calendar.current
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        day = calendar.component(.day, from: date)
        hour = calendar.component(.hour, from: date)
        minute = calendar.component(.minute, from: date)
        second = calendar.component(.second, from: date)
    }
}
