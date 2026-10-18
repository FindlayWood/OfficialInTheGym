//
//  MyDayFirestoreRangeLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import MyDayKit

/// The date strip's days, as one range query over `Users/{uid}/MyDay` by document id. The ids are
/// `yyyy-MM-dd`, which sort as dates, so a range on the id is a range on the day, and only the
/// days that have a document come back.
///
/// **The key format must match `MyDayFirestoreLoader` and `MyDayFirestoreSaver`** — the device's
/// own time zone, unlike the stats path's UTC `StatsDay`. A different format here would ask for
/// documents that were never written under that id.
///
/// Decodes per document and skips failures, as `FirestoreWorkoutTemplateFetcher` does: one day
/// written by an older build must not unmark the whole strip. Firestore answers from its local
/// cache, pending writes included, so a day logged offline is still marked.
struct MyDayFirestoreRangeLoader: MyDayRangeLoader {

    func loadDays(from start: Date, to end: Date) async throws -> [MyDayFullDayModel] {
        let userID = UserDefaults.currentUser.uid
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userID)/MyDay")
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: formatter.string(from: start))
            .whereField(FieldPath.documentID(), isLessThanOrEqualTo: formatter.string(from: end))
            .getDocuments()

        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: MyDayFullDayModel.self)
            } catch {
                print("❌ Skipping day \(document.documentID) for markers: \(error)")
                return nil
            }
        }
    }
}
