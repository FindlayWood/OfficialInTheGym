//
//  FirestoreLikeLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Which targets the signed-in user has liked: one document read per target,
/// in parallel. A page of comments is twenty reads — cheaper and simpler than
/// a collection-group query, which could not be scoped to one subject.
struct FirestoreLikeLoader: LikeLoader {

    let userId: String

    func likedTargets(among targets: [DiscoverLikeTarget]) async throws -> Set<DiscoverLikeTarget> {
        let db = Firestore.firestore()
        return try await withThrowingTaskGroup(of: DiscoverLikeTarget?.self) { group in
            for target in targets {
                group.addTask {
                    let snapshot = try await db.document(target.likePath(userId: userId)).getDocument()
                    return snapshot.exists ? target : nil
                }
            }
            var liked: Set<DiscoverLikeTarget> = []
            for try await target in group {
                if let target { liked.insert(target) }
            }
            return liked
        }
    }
}
