//
//  ProfileWorkoutSource.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation

/// Which list a workout row is in, which decides where tapping it goes
/// (`ProfileWorkoutDestination`).
enum ProfileWorkoutSource: Equatable {
    /// The profile's Workouts section and its see-all list: DISCOVER cards, every one live.
    case publicCards
    /// All workouts: the signed-in user's own library, private ones included.
    case library
}
