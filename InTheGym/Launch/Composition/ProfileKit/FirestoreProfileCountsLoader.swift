//
//  FirestoreProfileCountsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Reads `followerCount` / `followingCount` off `Profiles/{uid}`. A missing
/// document is `nil` (no profile yet), but a missing count is zero: a profile
/// nobody has followed has never had a count written.
struct FirestoreProfileCountsLoader: ProfileCountsLoader {

    func counts(for userId: String) async throws -> ProfileCounts? {
        let snapshot = try await Firestore.firestore().document("Profiles/\(userId)").getDocument()
        guard snapshot.exists else { return nil }
        return ProfileCounts(
            followers: snapshot.get("followerCount") as? Int ?? 0,
            following: snapshot.get("followingCount") as? Int ?? 0
        )
    }
}
