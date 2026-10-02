//
//  DiscoverWorkoutCard.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// One workout as DISCOVER lists it — the server-owned `DiscoverWorkouts/{id}`
/// card, projected from the top-level `WorkoutTemplates/{id}`.
///
/// DiscoverKit's own model, not MyDayKit's `WorkoutTemplateModel`: a list row
/// needs a title and a count, not the exercises and sets, and DiscoverKit
/// imports no other framework. The full template is only fetched when it is
/// actually needed (adding it to a day), and that happens in the composition
/// root.
///
/// Counts are optional for the reason given on `DiscoverExerciseCard`, and so
/// is `createdAt` — the projection writes `null` for a template without one.
public struct DiscoverWorkoutCard: Decodable, Identifiable, Hashable, Sendable {
    public let templateId: String
    public let title: String
    public let createdBy: String?
    public let exerciseCount: Int
    public let createdAt: Date?
    public let isPublic: Bool
    public let ratingCount: Int?
    public let ratingSum: Int?
    public let commentCount: Int?
    /// Tags shown on the subject, most-voted first — base tags always, community
    /// tags once enough people agree. Server-owned, absent until first tallied.
    public let visibleTags: [String]?
    /// Vote counts for the subject's most-voted tags, visible or not.
    public let tagCounts: [String: Int]?

    public var id: String { templateId }

    public init(
        templateId: String,
        title: String,
        createdBy: String?,
        exerciseCount: Int,
        createdAt: Date?,
        isPublic: Bool,
        ratingCount: Int? = nil,
        ratingSum: Int? = nil,
        commentCount: Int? = nil,
        visibleTags: [String]? = nil,
        tagCounts: [String: Int]? = nil
    ) {
        self.templateId = templateId
        self.title = title
        self.createdBy = createdBy
        self.exerciseCount = exerciseCount
        self.createdAt = createdAt
        self.isPublic = isPublic
        self.ratingCount = ratingCount
        self.ratingSum = ratingSum
        self.commentCount = commentCount
        self.visibleTags = visibleTags
        self.tagCounts = tagCounts
    }
}
