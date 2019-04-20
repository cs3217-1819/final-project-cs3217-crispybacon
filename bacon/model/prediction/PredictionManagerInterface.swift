//
//  PredictionManagerInterface.swift
//  bacon
//
//  Created by Travis Ching Jia Yea on 21/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

protocol PredictionManagerInterface {

    func getPrediction(_ time: Date, _ location: CodableCLLocation,
                       _ transactions: [Transaction]) -> Prediction?
    func savePrediction(_ prediction: Prediction) throws

}
