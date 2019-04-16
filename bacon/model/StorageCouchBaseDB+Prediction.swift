//
//  StorageCouchBaseDB+Prediction.swift
//  bacon
//
//  Created by Psychedelia on 17/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

extension StorageCouchBaseDB {

    func getNumberOfPredictionsInDatabase() -> Double {
        return Double(predictionDatabase.count)
    }

    func clearPredictionDatabase() throws {
        do {
            try predictionDatabase.delete()
            // Reinitialize database
            predictionDatabase = try StorageCouchBaseDB.openOrCreateEmbeddedDatabase(name: .predictions)
            log.info("Entered method StorageCouchBaseDB.clearPredictionDatabase()")
        } catch {
            if error is StorageError {
                log.warning("""
                    StorageCouchBaseDB.clearPredictionDatabase():
                    Encounter error while reinitializing prediction database.
                    Throwing StorageError.
                """)
                throw error
            } else {
                log.warning("""
                    StorageCouchBaseDB.clearPredictionDatabase():
                    Encounter error while clearing prediction database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Encounter error while clearing Prediction Database.")
            }
        }
    }

    func savePrediction(_ prediction: Prediction) throws {
        do {
            let predictionDocument = try createMutableDocument(from: prediction)
            try predictionDatabase.saveDocument(predictionDocument)
            log.info("""
                StorageCouchBaseDB.savePrediction() with arguments:
                prediction=\(prediction).
                """)
        } catch {
            if error is StorageError {
                throw error
            } else {
                log.info("""
                    StorageCouchBaseDB.savePrediction():
                    Encounter error saving prediction into database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Prediction couldn't be saved into database.")
            }
        }
    }

    func loadPredictions() throws -> [Prediction] {
        let query = QueryBuilder.select(SelectResult.all())
            .from(DataSource.database(predictionDatabase))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
        log.info("""
            StorageCouchBaseDB.loadPredictions()
            """)
        return try getPredictionsFromQuery(query)
    }

    func loadPredictions(limit: Int) throws -> [Prediction] {
        let query = QueryBuilder.select(SelectResult.all())
            .from(DataSource.database(predictionDatabase))
            .orderBy(Ordering.property(Constants.rawDateKey).descending())
            .limit(Expression.int(limit))
        log.info("""
            StorageCouchBaseDB.loadPredictions() with arguments:
            limit=\(limit).
            """)
        return try getPredictionsFromQuery(query)
    }

    private func getPredictionsFromQuery(_ query: Query) throws -> [Prediction] {
        do {
            var predictions: [Prediction] = Array()
            for result in try query.execute().allResults() {
                guard var predictionDictionary =
                    result.toDictionary()[DatabaseCollections.predictions.rawValue] as? [String: Any] else {
                        throw StorageError(message: "Could not read Document loaded from database as Dictionary.")
                }
                predictionDictionary.removeValue(forKey: Constants.rawDateKey)
                let predictionData = try JSONSerialization.data(withJSONObject: predictionDictionary, options: [])
                let currentPrediction = try JSONDecoder().decode(Prediction.self, from: predictionData)
                predictions.append(currentPrediction)
            }
            return predictions
        } catch {
            if error is DecodingError {
                log.warning("""
                    StorageCouchBaseDB.getPredictionsFromQuery():
                    Encounter error decoding data from database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Data loaded from database couldn't be decoded back as Prediction.")
            } else {
                log.warning("""
                    StorageCouchBaseDB.getPredictionsFromQuery():
                    Encounter error loading data from database.
                    Throwing StorageError.
                """)
                throw StorageError(message: "Predictions data couldn't be loaded from database.")
            }
        }
    }
}
