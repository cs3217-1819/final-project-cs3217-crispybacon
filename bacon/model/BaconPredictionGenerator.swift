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
        return Prediction(time: time, location: location, transactions: transactions, amount: 0.0, tags: Set<Tag>())
    }
}
