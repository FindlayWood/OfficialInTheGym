//
//  DiscoverBodyVote.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// One user's suggestion of what an exercise works — their whole set, as ids,
/// at `Exercises/{id}/BodyVotes/{uid}`, like a tag vote.
///
/// **A suggestion, never an edit.** A function tallies everyone's votes for a
/// curator to review; nothing a user sends here changes the exercise, because
/// its muscle groups decide every user's training balance
/// (CUSTOM_EXERCISES_PLAN.md step 11).
public struct DiscoverBodyVote: Hashable, Sendable {
    public let muscleGroups: [String]
    public let movementPatterns: [String]

    public init(muscleGroups: [String], movementPatterns: [String]) {
        self.muscleGroups = muscleGroups
        self.movementPatterns = movementPatterns
    }
}
