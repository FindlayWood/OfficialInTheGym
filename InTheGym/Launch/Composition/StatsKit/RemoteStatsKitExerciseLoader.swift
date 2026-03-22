//
//  RemoteStatsKitExerciseLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/03/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import StatsKit

class RemoteStatsKitExerciseLoader: StatsKitExerciseLoader {
    
    func load() async throws -> [ExerciseStats] {
        let userID = UserDefaults.currentUser.id
        let path = "Users/\(userID)/ExerciseStats"
        let ref = Firestore.firestore().collection(path)
        let snapshot = try await ref.getDocuments()
        
        let models = snapshot.documents.compactMap { doc in
            if let d = try? doc.data(as: ExerciseStats.self) {
                return d
            } else {
                return nil
            }
        }
        
        return models
    }
}

class RemoteRecentStatsKitExerciseLoader: StatsKitExerciseLoader {
    
    func load() async throws -> [ExerciseStats] {
        let userID = UserDefaults.currentUser.id
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: .now)!

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let components = cal.dateComponents([.year, .month, .day], from: cutoff)
        let midnight = cal.date(from: components)!
        let cutoffTimestamp = Timestamp(date: midnight)

        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userID)/ExerciseStats")
            .whereField("lastRecordDate", isGreaterThanOrEqualTo: cutoffTimestamp)
            .order(by: "lastRecordDate", descending: true)
            .limit(to: 3)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: ExerciseStats.self)
        }
    }
}

