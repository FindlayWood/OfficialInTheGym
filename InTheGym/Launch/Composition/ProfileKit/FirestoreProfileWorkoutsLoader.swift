//
//  FirestoreProfileWorkoutsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import DiscoverKit
import FirebaseFirestore
import ProfileKit

/// A user's newest public, visible workouts: `DiscoverWorkouts` where `createdBy` is them, with the
/// `isPublic` / `status` filters every DISCOVER card query carries, which the rules require. The
/// shape of `FirestoreProfileClipsLoader`. Needs the composite index
/// `(createdBy, isPublic, status, createdAt desc)` in `PROFILE_WORKOUTS_PLAN.md` step 6.
///
/// Decoded as DISCOVER's own `DiscoverWorkoutCard`, per document (`DiscoverCardQuery.page`), so a
/// card the profile can show is exactly one DISCOVER can. The average comes from
/// `RatingSummary.average`, the one definition of a displayed average.
struct FirestoreProfileWorkoutsLoader: ProfileWorkoutsLoader {

    func publicWorkouts(of userId: String, limit: Int) async throws -> [ProfileWorkout] {
        let query = Firestore.firestore().collection("DiscoverWorkouts")
            .whereField("createdBy", isEqualTo: userId)
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "visible")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        let cards = try await DiscoverCardQuery.page(query, as: DiscoverWorkoutCard.self)
        return cards.map { card in
            ProfileWorkout(
                workoutId: card.templateId,
                title: card.title,
                createdBy: card.createdBy,
                exerciseCount: card.exerciseCount,
                createdAt: card.createdAt,
                isPublic: card.isPublic,
                ratingCount: card.ratingCount,
                ratingSum: card.ratingSum,
                averageRating: card.ratingSummary.average,
                commentCount: card.commentCount,
                tags: card.visibleTags
            )
        }
    }
}
