//
//  DiscoverWorkoutCommunity.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// How a workout goes for everyone who has done it: the card's `community` field, written only by
/// the `discoverWorkoutCommunity` Cloud Function.
///
/// **People who saved a copy count as having done it.** A DISCOVER workout saved to a library is a
/// copy with its own id, and the server counts its sessions toward the workout it came from, so
/// these numbers are about this workout wherever people did it.
///
/// **The server writes nothing until three people have done it**: the card is readable by everyone,
/// and an average over one or two people is their own sessions. `isShowable` checks the same
/// threshold again so a card written before the rule could never draw one person's numbers.
///
/// The averages are optional for the reason MyDay's `WorkoutHistorySummary`'s are: each is taken
/// only over the sessions that carry it, and one no session carries is absent, never 0.
public struct DiscoverWorkoutCommunity: Decodable, Hashable, Sendable {
    public let peopleCount: Int
    public let sessionCount: Int
    public let averageDurationSeconds: Int?
    public let averageRPE: Double?

    /// Must equal `MIN_PEOPLE` in the functions' `Discover/Community/WorkoutCommunityStats.ts`.
    public static let minimumPeople = 3

    public init(peopleCount: Int, sessionCount: Int, averageDurationSeconds: Int? = nil, averageRPE: Double? = nil) {
        self.peopleCount = peopleCount
        self.sessionCount = sessionCount
        self.averageDurationSeconds = averageDurationSeconds
        self.averageRPE = averageRPE
    }

    public var isShowable: Bool { peopleCount >= Self.minimumPeople }
}
