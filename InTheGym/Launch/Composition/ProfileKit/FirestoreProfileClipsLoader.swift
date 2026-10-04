//
//  FirestoreProfileClipsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// A user's newest public, visible clips: `DiscoverClips` where `createdBy` is
/// them, with the same `isPublic` / `status` filters every DISCOVER card query
/// carries, which the rules require. Needs the composite index
/// `(createdBy, isPublic, status, uploadedAt desc)` in `PROFILE_PLAN.md` step 8.
/// `profileClipCount` counts the same set.
struct FirestoreProfileClipsLoader: ProfileClipsLoader {

    func clips(of userId: String, limit: Int) async throws -> [ProfileClip] {
        let snapshot = try await Firestore.firestore().collection("DiscoverClips")
            .whereField("createdBy", isEqualTo: userId)
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "visible")
            .order(by: "uploadedAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.map { document in
            ProfileClip(
                clipId: document.documentID,
                exerciseId: document.get("exerciseId") as? String,
                exerciseName: document.get("exerciseName") as? String,
                videoURL: document.get("videoURL") as? String,
                thumbnailURL: document.get("thumbnailURL") as? String,
                durationSeconds: (document.get("durationSeconds") as? NSNumber)?.doubleValue,
                createdBy: document.get("createdBy") as? String,
                uploadedAt: (document.get("uploadedAt") as? Timestamp)?.dateValue(),
                likeCount: (document.get("likeCount") as? NSNumber)?.intValue,
                commentCount: (document.get("commentCount") as? NSNumber)?.intValue,
                viewCount: (document.get("viewCount") as? NSNumber)?.intValue
            )
        }
    }
}
