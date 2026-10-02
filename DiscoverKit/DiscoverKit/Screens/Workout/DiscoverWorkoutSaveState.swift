//
//  DiscoverWorkoutSaveState.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// Where saving a workout to the user's library stands. `.unavailable` covers
/// the user's own workout (it is already theirs) and the coach tab bar, which
/// has no library to save into.
enum DiscoverWorkoutSaveState: Equatable {
    case unavailable
    case checking
    case idle
    case saving
    case saved
    case failed
}
