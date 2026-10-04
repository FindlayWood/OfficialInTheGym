//
//  ProfileHighlight+Firestore.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import ProfileKit

extension ProfileHighlight {

    /// One highlight from Firestore data shaped like `highlightFromStats`
    /// in the functions: a `ProfileHighlights` entry or an `ExerciseStats`
    /// document. **The one place that shape is read**, by both
    /// `FirestoreProfileHighlightsLoader` and `FirestoreHighlightCandidatesLoader`.
    /// `isTimeBased` falls back to StatsKit's rule when the data has no flag,
    /// as an `ExerciseStats` document does not.
    init?(highlightData data: [String: Any], exerciseId fallbackId: String? = nil) {
        guard let exerciseId = data["exerciseId"] as? String ?? data["exerciseID"] as? String ?? fallbackId else {
            return nil
        }
        let maxWeight = (data["maxWeight"] as? NSNumber)?.doubleValue ?? 0
        let maxTime = (data["maxTime"] as? NSNumber)?.intValue ?? 0
        let totalTime = (data["totalTime"] as? NSNumber)?.intValue ?? 0
        self.init(
            exerciseId: exerciseId,
            exerciseName: data["exerciseName"] as? String ?? "",
            maxWeightKilograms: maxWeight,
            maxTimeSeconds: maxTime,
            isTimeBased: data["isTimeBased"] as? Bool ?? (maxWeight == 0 && totalTime > 0)
        )
    }
}
