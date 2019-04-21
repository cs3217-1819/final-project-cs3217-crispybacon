//
//  PredictionGenerator.swift
//  bacon
//
//  Created by Lizhi Zhang on 14/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// This provides an abstraction layer over the underlying prediction generation logic.
/// This localizes any changes needed when swapping out the underlying prediction generator.
class PredictionGenerator {

    private let concretePredictor: BaconPredictionGenerator

    init() {
        log.info("""
            PredictionGenerator initialized using PredictionGenerator.init()
            """)
        concretePredictor = BaconPredictionGenerator()
    }

    /// Makes a prediction based on the input arguments and an array of past Transactions.
    func predict(_ time: Date, _ location: CodableCLLocation, _ transactions: [Transaction]) -> Prediction? {
        return concretePredictor.predict(time, location, transactions)
    }
}
