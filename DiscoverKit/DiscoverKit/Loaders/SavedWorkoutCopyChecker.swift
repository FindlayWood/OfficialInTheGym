//
//  SavedWorkoutCopyChecker.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// Whether the signed-in user's library already holds a copy of a workout —
/// so the page says "Saved" rather than offering to save it a second time.
public protocol SavedWorkoutCopyChecker {
    func hasSavedCopy(ofWorkout templateId: String) async -> Bool
}
