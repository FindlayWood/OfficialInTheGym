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

    /// How far back to fetch.
    ///
    /// **This is not the window any screen displays — it is the widest window
    /// any screen *computes* from.** The longest range offered is 2M (60 days),
    /// and every ACWR point in it needs the 28 days of chronic history ending on
    /// that day. Fetching only as far back as the displayed range leaves the
    /// oldest points with a chronic window that reaches outside the data, so
    /// chronic comes out too low and the ratio too high — the chart reads
    /// "high risk" the further left you look. 60 + 28 rounded up for headroom.
    private static let daysToFetch = 120

    func fetchDailyTotals() async throws -> [DailyTotal] {
        let userID = UserDefaults.currentUser.id
        let cutoffTimestamp = Timestamp(
            date: StatsDay.startOfDay(daysAgo: Self.daysToFetch)
        )

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
