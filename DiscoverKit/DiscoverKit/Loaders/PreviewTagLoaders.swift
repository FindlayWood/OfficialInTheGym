//
//  PreviewTagLoaders.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer for every tag read DiscoverKit makes. One type because a
/// preview needs the directory, a tag's page and the user's votes to agree.
public final class PreviewTagLoaders: PopularTagsLoader, TagSuggestionLoader, TaggedExercisesLoader,
                                      TaggedWorkoutsLoader, MyTagVotesLoader, @unchecked Sendable {
    public init() {}

    public func popularTags(limit: Int) async throws -> [DiscoverTag] {
        Array(Self.tags.prefix(limit))
    }

    public func tags(startingWith prefix: String, limit: Int) async throws -> [DiscoverTag] {
        Array(Self.tags.filter { $0.tag.hasPrefix(prefix) }.prefix(limit))
    }

    public func exercises(taggedWith tag: String, limit: Int, after last: DiscoverTagged<DiscoverExerciseCard>?) async throws -> [DiscoverTagged<DiscoverExerciseCard>] {
        PreviewDiscoverExerciseCardLoader.cards.enumerated()
            .map { DiscoverTagged(card: $0.element, voteCount: 12 - $0.offset) }
            .previewPage(limit: limit, after: last)
    }

    public func workouts(taggedWith tag: String, limit: Int, after last: DiscoverTagged<DiscoverWorkoutCard>?) async throws -> [DiscoverTagged<DiscoverWorkoutCard>] {
        PreviewDiscoverWorkoutCardLoader.cards.prefix(6).enumerated()
            .map { DiscoverTagged(card: $0.element, voteCount: 6 - $0.offset) }
            .previewPage(limit: limit, after: last)
    }

    public func myTags(on subject: DiscoverSubject) async throws -> [String] {
        ["hotel"]
    }

    static let tags: [DiscoverTag] = [
        ("legs", 14), ("chest", 11), ("upperbody", 9), ("lowerbody", 9), ("push", 7), ("pull", 6),
        ("hinge", 4), ("quads", 4), ("hamstrings", 3), ("core", 3), ("glutes", 2), ("hotel", 1)
    ].map { DiscoverTag(tag: $0.0, totalCount: $0.1) }
}
