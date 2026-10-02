//
//  DiscoverWorkoutExercise.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// One exercise of a workout and its prescribed sets.
public struct DiscoverWorkoutExercise: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let sets: [DiscoverWorkoutSet]
    public let notes: String?

    public init(id: String, name: String, sets: [DiscoverWorkoutSet], notes: String?) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
    }

    /// `4 × 8 · 80 kg`, `3 × 8–12`, `5 × 400 m`, `1 set`. Every set the same
    /// reads as one line; where they differ the reps become a range and a
    /// varying load is left out rather than averaged into a number nobody
    /// prescribed.
    var summary: String {
        guard !sets.isEmpty else { return "No sets" }
        var parts: [String] = []

        let reps = sets.compactMap(\.reps)
        if let low = reps.min(), let high = reps.max(), reps.count == sets.count {
            parts.append("\(sets.count) × " + (low == high ? "\(low)" : "\(low)–\(high)"))
        } else {
            parts.append(sets.count == 1 ? "1 set" : "\(sets.count) sets")
        }

        for measure in [sets.map(\.loadText), sets.map(\.timeText), sets.map(\.distanceText)] {
            if let first = measure.first ?? nil, measure.allSatisfy({ $0 == first }) {
                parts.append(first)
            }
        }
        return parts.joined(separator: " · ")
    }
}
