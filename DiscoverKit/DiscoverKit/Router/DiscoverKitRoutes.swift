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
}
