//
//  StatsKitDailyTotalsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/03/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import StatsKit

class StatsKitDailyTotalsLoader: DailyTotalsProviding {
    func fetchDailyTotals() async throws -> [DailyTotal] {
        let userID = UserDefaults.currentUser.id
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: .now)!

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let components = cal.dateComponents([.year, .month, .day], from: cutoff)
        let midnight = cal.date(from: components)!
        let cutoffTimestamp = Timestamp(date: midnight)

        let path = "Users/\(userID)/DailyTotals"
        let snapshot = try await Firestore.firestore()
            .collection(path)
            .whereField("date", isGreaterThanOrEqualTo: cutoffTimestamp)
            .order(by: "date", descending: false)
            .getDocuments()
        

        let models = snapshot.documents.compactMap { doc in
            if let d = try? doc.data(as: DailyTotal.self) {
                return d
            } else {
                return nil
            }
        }
        
        return models
    }
}
