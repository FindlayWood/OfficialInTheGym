//
//  DiscoverExerciseCard.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// One exercise as DISCOVER lists it — the server-owned `DiscoverExercises/{id}`
/// card, never the `Exercises` catalogue document itself.
///
/// **Every engagement count is optional.** A card is created by the projection
/// trigger with none of them, and each count only appears once its own trigger
/// first writes it. A non-optional count would fail to decode every card that
/// nobody has rated or commented on yet — which, at launch, is all of them.
///
/// `category` stays the raw string (`upper_body`) rather than MyDayKit's
/// `ExerciseCategory`: DiscoverKit defines only what it needs and imports no
/// other framework. `categoryDisplayName` is the one place it is made readable.
public struct DiscoverExerciseCard: Decodable, Identifiable, Hashable, Sendable {
    public let exerciseId: String
    public let name: String
    public let category: String?
    public let ratingCount: Int?
    public let ratingSum: Int?
    public let commentCount: Int?
    /// Tags shown on the subject, most-voted first — base tags always, community
    /// tags once enough people agree. Server-owned, absent until first tallied.
    public let visibleTags: [String]?
    /// Vote counts for the subject's most-voted tags, visible or not.
    public let tagCounts: [String: Int]?

    public var id: String { exerciseId }

    public init(
        exerciseId: String,
        name: String,
        category: String?,
        ratingCount: Int? = nil,
        ratingSum: Int? = nil,
        commentCount: Int? = nil,
        visibleTags: [String]? = nil,
        tagCounts: [String: Int]? = nil
    ) {
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.ratingCount = ratingCount
        self.ratingSum = ratingSum
        self.commentCount = commentCount
        self.visibleTags = visibleTags
        self.tagCounts = tagCounts
    }

    /// `upper_body` → `Upper Body`.
    var categoryDisplayName: String? {
        category.map {
            $0.split(separator: "_").map { $0.capitalized }.joined(separator: " ")
        }
    }
}
