//
//  PreviewBodyPartServices.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Fixed lists and a vote that saves nothing, for SwiftUI previews.
public struct PreviewBodyPartServices: BodyPartsLoader, MyBodyVoteLoader, BodyVoteWriter, Sendable {

    public init() {}

    public func loadBodyParts() async throws -> DiscoverBodyParts {
        DiscoverBodyParts(
            muscleGroups: [
                DiscoverBodyPart(id: "chest", name: "Chest"),
                DiscoverBodyPart(id: "shoulders", name: "Shoulders"),
                DiscoverBodyPart(id: "triceps", name: "Triceps"),
                DiscoverBodyPart(id: "quads", name: "Quadriceps"),
                DiscoverBodyPart(id: "glutes", name: "Glutes")
            ],
            movementPatterns: [
                DiscoverBodyPart(id: "push_horizontal", name: "Push Horizontal"),
                DiscoverBodyPart(id: "squat", name: "Squat"),
                DiscoverBodyPart(id: "hinge", name: "Hinge")
            ]
        )
    }

    public func myBodyVote(onExercise exerciseId: String) async throws -> DiscoverBodyVote? { nil }

    public func setMyBodyVote(_ vote: DiscoverBodyVote, onExercise exerciseId: String) async throws {}
}
