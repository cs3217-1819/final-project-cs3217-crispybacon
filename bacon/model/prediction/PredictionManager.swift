//
//  PredictionManager.swift
//  bacon
//
//  Created by Lizhi Zhang on 14/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// Manages predictions.
class PredictionManager: PredictionManagerInterface {

    private let storageManager: StorageManagerInterface
    private let predictionGeneraor: PredictionGenerator

    /// Instantiates a PredictionManager.
    /// A PredictionManager is backed internally by a StorageManager.
    /// - Throws: Rethrows any error encountered while instantiating a StorageManager.
    init() throws {
        storageManager = try StorageManager()
        predictionGeneraor = PredictionGenerator()
        log.info("""
            PredictionManager initialized using PredictionManager.init()
            """)
    }

    func getPrediction(_ time: Date, _ location: CodableCLLocation,
                       _ transactions: [Transaction]) -> Prediction? {
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
