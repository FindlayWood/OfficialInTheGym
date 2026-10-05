//
//  DiscoverSectionState.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// The state of one home-screen section. Each section loads and fails on its
/// own: clips failing is no reason to blank the workouts beneath them.
///
/// **`.failed` is its own state, never folded into an empty `.loaded`** — the
/// lesson of the workout library, which mapped every error to "no workouts"
/// and told users they had nothing when the network had simply dropped.
enum DiscoverSectionState<Value> {
    case loading
    case loaded(Value)
    case failed
}

/// For the search view model's tests, which compare whole states.
extension DiscoverSectionState: Equatable where Value: Equatable {}
