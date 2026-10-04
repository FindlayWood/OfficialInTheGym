//
//  ProfileLoadState.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Foundation

/// The state of something on a profile that loads. `.failed` is a state of its
/// own, rendered with a way to retry, rather than collapsing into an empty
/// screen. `WorkoutLibraryManager` mapped every error to `.empty` once, and the
/// library showed "no workouts" to people who had dozens.
enum ProfileLoadState<Value> {
    case loading
    case loaded(Value)
    case failed
}
