//
//  ProfileWorkoutsLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation

/// Loads a user's newest public, visible workouts: the same cards DISCOVER lists for them, so the
/// profile and DISCOVER can never disagree about which workouts are public, or which moderation has
/// hidden. Your own profile reads exactly this too, because the profile is what others see.
public protocol ProfileWorkoutsLoader {
    func publicWorkouts(of userId: String, limit: Int) async throws -> [ProfileWorkout]
}
