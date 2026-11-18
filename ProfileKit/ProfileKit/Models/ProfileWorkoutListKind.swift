//
//  ProfileWorkoutListKind.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation

/// The two full lists of workouts a profile opens. One screen draws both
/// (`ProfileWorkoutListScreen`); they differ in what they read and where a row goes.
enum ProfileWorkoutListKind: Equatable {
    /// The section's See all: that person's public workouts, as everyone sees them.
    case publicWorkouts(userId: String)
    /// All workouts: the signed-in user's whole library, private ones included.
    case library

    var source: ProfileWorkoutSource {
        switch self {
        case .publicWorkouts: .publicCards
        case .library: .library
        }
    }

    var title: String {
        switch self {
        case .publicWorkouts: "Workouts"
        case .library: "All workouts"
        }
    }

    /// Building starts only from MyDay, so the library's empty state says where, rather than
    /// offering a Create button Profile does not have.
    var emptyMessage: String {
        switch self {
        case .publicWorkouts: "No public workouts yet."
        case .library: "Workouts you build in MyDay show here."
        }
    }
}
