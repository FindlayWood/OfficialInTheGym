//
//  DiscoverBodyParts.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Every muscle group and movement pattern an exercise can work — what the
/// "Works" line names and the suggestion sheet offers.
public struct DiscoverBodyParts: Hashable, Sendable {
    public let muscleGroups: [DiscoverBodyPart]
    public let movementPatterns: [DiscoverBodyPart]

    public init(muscleGroups: [DiscoverBodyPart], movementPatterns: [DiscoverBodyPart]) {
        self.muscleGroups = muscleGroups
        self.movementPatterns = movementPatterns
    }

    /// The names for `ids`, in the order given. An id the lists do not hold is
    /// left out rather than shown raw.
    func names(muscleGroups groupIds: [String], movementPatterns patternIds: [String]) -> [String] {
        let groups = Dictionary(uniqueKeysWithValues: muscleGroups.map { ($0.id, $0.name) })
        let patterns = Dictionary(uniqueKeysWithValues: movementPatterns.map { ($0.id, $0.name) })
        return groupIds.compactMap { groups[$0] } + patternIds.compactMap { patterns[$0] }
    }
}
