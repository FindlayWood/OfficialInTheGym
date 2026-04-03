//
//  RemoteExerciseDailyStatsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import StatsKit

class RemoteExerciseDailyStatsLoader: ExerciseDailyStatsProviding {
    
    func fetchDailyStats(exerciseID: String, from: Date) async throws -> [ExerciseDailyStats] {
        let userID = UserDefaults.currentUser.id
        let path = "Users/\(userID)/ExerciseStats/\(exerciseID)/DailyStats"
        
        let snapshot = try await Firestore.firestore()
            .collection(path)
            .whereField("date", isGreaterThanOrEqualTo: from)
            .order(by: "date", descending: false)
            .getDocuments()
        

        let models = snapshot.documents.compactMap { doc in
            if let d = try? doc.data(as: ExerciseDailyStats.self) {
                return d
            } else {
                return nil
            }
        }
        
        return models
    }
}
