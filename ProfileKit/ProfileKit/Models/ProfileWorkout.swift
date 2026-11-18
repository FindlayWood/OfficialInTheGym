//
//  ProfileWorkout.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation

/// A workout as the profile shows it: ProfileKit's own read model, the third beside MyDayKit's
/// `WorkoutTemplateModel` (the workout itself) and DiscoverKit's `DiscoverWorkoutCard` (its public
/// card). ProfileKit imports neither, so the composition root maps each into this.
///
/// It comes from two places. **Someone's public workouts** are DISCOVER cards, and carry ratings,
/// comments and tags. **Your own library** is MyDay's templates, which carry none of that, so on a
/// library row those fields are `nil`. **Every count stays optional** for the reason card counts
/// are: a workout nobody has rated has no rating, not a rating of zero.
///
/// `averageRating` is worked out by the composition root with DISCOVER's
/// `RatingSummary.average`, the one definition of a displayed average, rather than re-derived here.
/// The raw count and sum travel too, so the public page can be opened without a second read.
public struct ProfileWorkout: Identifiable, Hashable, Sendable {
    public let workoutId: String
    public let title: String
    public let createdBy: String?
    public let exerciseCount: Int
    public let createdAt: Date?
    public let isPublic: Bool
    public let ratingCount: Int?
    public let ratingSum: Int?
    public let averageRating: Double?
    public let commentCount: Int?
    public let tags: [String]?

    public var id: String { workoutId }

    public init(
        workoutId: String,
        title: String,
        createdBy: String?,
        exerciseCount: Int,
        createdAt: Date?,
        isPublic: Bool,
        ratingCount: Int? = nil,
        ratingSum: Int? = nil,
        averageRating: Double? = nil,
        commentCount: Int? = nil,
        tags: [String]? = nil
    ) {
        self.workoutId = workoutId
        self.title = title
        self.createdBy = createdBy
        self.exerciseCount = exerciseCount
        self.createdAt = createdAt
        self.isPublic = isPublic
        self.ratingCount = ratingCount
        self.ratingSum = ratingSum
        self.averageRating = averageRating
        self.commentCount = commentCount
        self.tags = tags
    }

    /// The lock in the row's corner. Only a library row can be private: the public section and
    /// its see-all list are DISCOVER cards, which exist only for public workouts.
    var showsLock: Bool { !isPublic }
}
