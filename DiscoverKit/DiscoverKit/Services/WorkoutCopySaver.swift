//
//  WorkoutCopySaver.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// Saves a copy of a public workout into the signed-in user's own library.
///
/// **A copy, never a reference**: the saved workout is theirs, private, and
/// does not change when its author edits the original. It is saved to the
/// library only — putting it on a day is MyDay's job, from the library.
public protocol WorkoutCopySaver {
    func saveCopy(ofWorkout templateId: String) async throws
}
