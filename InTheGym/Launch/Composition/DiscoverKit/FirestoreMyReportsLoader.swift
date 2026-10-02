//
//  FirestoreMyReportsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// The signed-in user's own reports, read back as targets — the rules let a
/// reporter read their own reports and nobody else's.
struct FirestoreMyReportsLoader: MyReportsLoader {

    let userId: String

    func reportedTargets() async throws -> Set<DiscoverReportTarget> {
        let snapshot = try await Firestore.firestore()
            .collection("Reports")
            .whereField("reporterId", isEqualTo: userId)
            .getDocuments()
        return Set(snapshot.documents.compactMap { document in
            guard let path = document.get("targetPath") as? String,
                  let kind = document.get("targetKind") as? String else { return nil }
            return DiscoverReportTarget(targetPath: path, targetKind: kind)
        })
    }
}
