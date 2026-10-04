//
//  ProfileHighlight.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// One PB tile: an exercise and its best, a weight in kilograms or, for timed
/// work, a time in seconds. From `ProfileHighlights/{uid}`, built server-side
/// from the user's `ExerciseStats`, which no one else can read.
///
/// `isTimeBased` is StatsKit's rule (no weight ever lifted, some time logged),
/// worked out on the server so every reader agrees.
public struct ProfileHighlight: Equatable, Identifiable, Sendable {
    public let exerciseId: String
    public let exerciseName: String
    public let maxWeightKilograms: Double
    public let maxTimeSeconds: Int
    public let isTimeBased: Bool

    public var id: String { exerciseId }

    public init(exerciseId: String, exerciseName: String, maxWeightKilograms: Double, maxTimeSeconds: Int, isTimeBased: Bool) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.maxWeightKilograms = maxWeightKilograms
        self.maxTimeSeconds = maxTimeSeconds
        self.isTimeBased = isTimeBased
    }

    /// "140 kg", or "2m 30s" for timed work. Kilograms, the unit stats are
    /// stored in, since there is no app-wide unit preference to read yet.
    var valueText: String {
        if isTimeBased {
            let minutes = maxTimeSeconds / 60
            let seconds = maxTimeSeconds % 60
            if minutes == 0 { return "\(seconds)s" }
            return seconds == 0 ? "\(minutes)m" : "\(minutes)m \(seconds)s"
        }
        return ProfileWeightUnit.kilograms.display(kilograms: maxWeightKilograms)
    }
}
