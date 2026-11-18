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
    /// Its place in a workout that has supersets — "1a", "2" — worked out by the composition root
    /// from MyDayKit's `WorkoutSupersetLayout`, the one definition. `nil` on a workout with none,
    /// which numbers its exercises 1, 2, 3 as it always has. DiscoverKit never derives it.
    public let supersetLabel: String?
    /// Whether the next exercise is in the same superset, so the page joins the two rows.
    public let continuesSuperset: Bool

    public init(
        id: String,
        name: String,
        sets: [DiscoverWorkoutSet],
        notes: String?,
        supersetLabel: String? = nil,
        continuesSuperset: Bool = false
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
        self.supersetLabel = supersetLabel
        self.continuesSuperset = continuesSuperset
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
