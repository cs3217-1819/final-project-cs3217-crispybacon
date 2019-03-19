//
//  StorageManager.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol StorageManager {
    // API to be called embedded MongoDB
    func saveTransaction()
    // func loadTransaction() with different filters
}
