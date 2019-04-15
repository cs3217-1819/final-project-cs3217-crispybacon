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
            if isSimilarInTime(time, transaction) && isSimilarInLocation(location, transaction) {
                similarTransactions.insert(transaction)
            }
        }
        return generatePredictionFromSimilarTransactions(time, location, similarTransactions, transactions)
    }

    private func isSimilarInTime(_ time: Date, _ transaction: Transaction) -> Bool {
        let calendar = Calendar.current
        let time1 = time
        let time2 = transaction.date

        // Take out only the hour and minute of time1
        let components = calendar.dateComponents([.hour, .minute, .second], from: time1)
        guard let hour = components.hour, let minute = components.minute, let second = components.second else {
            return false
        }
        // Map the hour and minute components of time1 to time2, so the two times have the same date
        let time3 = calendar.date(bySettingHour: hour, minute: minute, second: second, of: time2)
        guard let mappedTime1 = time3 else {
            return false
        }
        // Now take the difference between time2 and mappedTime1
        let difference = calendar.dateComponents([.hour, .minute], from: mappedTime1, to: time2)
        guard let hourDiff = difference.hour, let minuteDiff = difference.minute else {
            return false
        }
        // Calculate the number of minutes between the two times
        // Taking into consideration of wrapping around at mid-night
        let absHourDiff = abs(hourDiff)
        let absMinuteDiff = abs(minuteDiff)
        let totalDiffInMin = absHourDiff * 60 + absMinuteDiff
        let reverseTotalDiffInMin = 24 * 60 - totalDiffInMin
        let finalDiffInMin = min(totalDiffInMin, reverseTotalDiffInMin)

        if finalDiffInMin <= Constants.timeSimilarityThreshold {
            return true
        }
        return false
    }

    private func isSimilarInLocation(_ location: CodableCLLocation, _ transaction: Transaction) -> Bool {
        guard let location1 = transaction.location?.location else {
            return false
        }
        let location2 = location.location
        if location1.distance(from: location2) <= Constants.locationSimilarityThreshold {
            return true
        }
        return false
    }

    private func generatePredictionFromSimilarTransactions(_ time: Date,
                                                           _ location: CodableCLLocation,
                                                           _ similarTransactions: Set<Transaction>,
                                                           _ pastTransactions: [Transaction]) -> Prediction {
        var amountPredicted = Constants.defaultPredictedAmount
        var tagsPredicted = Set<Tag>()
        var amountCount = [Decimal: Int]()
        for transaction in similarTransactions {
            for tag in transaction.tags {
                tagsPredicted.insert(tag)
            }
            amountCount[transaction.amount] = (amountCount[transaction.amount] ?? 0) + 1
        }
        if let mostFrequentAmount = amountCount.max(by: { first, second in first.value < second.value })?.key {
            amountPredicted = mostFrequentAmount
        }
        return Prediction(time: time, location: location,
                          transactions: pastTransactions, amount: amountPredicted, tags: tagsPredicted)
    }
}
