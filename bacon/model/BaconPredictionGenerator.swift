//
//  BaconPredictionGenerator.swift
//  bacon
//
//  Created by Lizhi Zhang on 14/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CoreLocation

class BaconPredictionGenerator {

    func predict(_ time: Date, _ location: CodableCLLocation, _ transactions: [Transaction]) -> Prediction {
        var similarTransactions = Set<Transaction>()
        for transaction in transactions {
            isSimilarInTime(time, transaction)
        }

        return Prediction(time: time, location: location, transactions: transactions, amount: 0.0, tags: Set<Tag>())
    }

    private func isSimilarInTime(_ time: Date, _ transaction: Transaction) -> Bool {
        let calendar = Calendar.current
        //let time1 = time
        //let time2 = transaction.date
        let formatter = Constants.getDateFormatter()
        let time1 = formatter.date(from: "2019-04-15 17:44")!
        let time2 = formatter.date(from: "2019-03-18 16:59")!
        
        // Take out only the hour and minute of time1
        let components = calendar.dateComponents([.hour, .minute, .second], from: time1)
        guard let hour = components.hour, let minute = components.minute, let second = components.second else {
            return false
        }
        // Map the hour and minute components to time2
        let time3 = calendar.date(bySettingHour: hour, minute: minute, second: second, of: time2)
        guard let mappedTime = time3 else {
            return false
        }
        // Now take the difference between time1 and mappedTime (they should have the same date now)
        let difference = calendar.dateComponents([.hour, .minute], from: time1, to: mappedTime)
        let hours = difference.hour!
        let minutes = difference.minute!
        print(hours)
        print(minutes)
        return false
    }
}
