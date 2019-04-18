//
//  PredictionManager.swift
//  bacon
//
//  Created by Lizhi Zhang on 14/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class PredictionManager {

    private let storageManager: StorageManagerInterface
    private let predictionGeneraor: PredictionGenerator

    init() throws {
        storageManager = try StorageManager()
        predictionGeneraor = PredictionGenerator()
        log.info("""
            PredictionManager initialized using PredictionManager.init()
            """)
    }

    func getPrediction(_ time: Date, _ location: CodableCLLocation,
                       _ transactions: [Transaction]) -> Prediction? {
        // before generating a new prediction, should seek a similar prediction
        let newPrediction = getPredictionFromGenerator(time, location, transactions)
        return newPrediction
    }

    private func getPredictionFromGenerator(_ time: Date, _ location: CodableCLLocation,
                                            _ transactions: [Transaction]) -> Prediction? {
       return predictionGeneraor.predict(time, location, transactions)
    }

    func savePrediction(_ prediction: Prediction) throws {
        try storageManager.savePrediction(prediction)
    }
}
