//
//  PredictionManagerInterface.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 21/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

/// An interface for all Prediction-related functionalities.
protocol PredictionManagerInterface {
    /// Retrieves and returns a prediction.
    func getPrediction(_ time: Date, _ location: CodableCLLocation,
                       _ transactions: [Transaction]) -> Prediction?

    /// Saves a prediction.
    /// - Throws: Rethrows any error encountered during the operation.
    func savePrediction(_ prediction: Prediction) throws
}
