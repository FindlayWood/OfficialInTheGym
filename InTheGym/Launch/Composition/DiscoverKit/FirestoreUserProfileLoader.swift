//
//  FirestoreUserProfileLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Reads `Users/{uid}` for a set of ids, thirty at a time — the most one
/// Firestore `in` query accepts. Only `username` and `displayName` are read,
/// by hand, rather than decoding the whole `Users` model: that model lives in
/// the app target and is non-optional in ways a comment row does not need to
/// break on.
struct FirestoreUserProfileLoader: UserProfileLoader {

    static let batchSize = 30

    func profiles(for userIds: Set<String>) async throws -> [String: DiscoverUserProfile] {
        let ids = Array(userIds)
        let batches = stride(from: 0, to: ids.count, by: Self.batchSize).map {
            Array(ids[$0..<min($0 + Self.batchSize, ids.count)])
        }
        let users = Firestore.firestore().collection("Users")

        return try await withThrowingTaskGroup(of: [DiscoverUserProfile].self) { group in
            for batch in batches {
                group.addTask {
                    let snapshot = try await users.whereField(FieldPath.documentID(), in: batch).getDocuments()
                    return snapshot.documents.map { document in
                        DiscoverUserProfile(
                            userId: document.documentID,
                            username: document.get("username") as? String ?? "",
                            displayName: document.get("displayName") as? String ?? ""
                        )
                    }
                }
            }
            var profiles: [String: DiscoverUserProfile] = [:]
            for try await batch in group {
                for profile in batch { profiles[profile.userId] = profile }
            }
            return profiles
        }
    }
}
