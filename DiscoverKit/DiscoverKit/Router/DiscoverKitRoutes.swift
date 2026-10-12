//
//  DiscoverKitRoutes.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

enum DiscoverKitRoutes {
    case home
    case allClips
    case allWorkouts
    case allExercises
    case exerciseDetail(DiscoverExerciseCard)
    case workoutDetail(DiscoverWorkoutCard)
    case comments(DiscoverSubject)
    case clipPlayer(DiscoverClipCard)
    case tag(String)
    case blockedUsers
    case search

    /// Whether this screen is part of INTHEGYM pro. **The one place that is decided** —
    /// `DiscoverKitRouter.navigate(to:)` is the only way any screen is pushed, so a route marked
    /// here is gated from every way in: the home, see-all, an exercise page, and ProfileKit's
    /// clips grid through `showClip`.
    var requiresPro: Bool {
        switch self {
        case .clipPlayer:
            return true
        case .home, .allClips, .allWorkouts, .allExercises, .exerciseDetail, .workoutDetail,
             .comments, .tag, .blockedUsers, .search:
            return false
        }
    }
}
