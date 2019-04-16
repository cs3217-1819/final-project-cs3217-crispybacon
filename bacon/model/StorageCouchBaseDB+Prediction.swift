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
}
