//
//  ProfileWorkoutDestination.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation

/// Where tapping a workout row goes. **The one definition of that rule**: the section, its see-all
/// list and All workouts all read it, so no list re-derives it.
///
/// - `.choice`: your own workout in a public list. Both pages exist, so the user picks between
///   MyDay's page (Add to Today, Schedule) and DISCOVER's (ratings, comments).
/// - `.workout`: any row in All workouts, public or private. **The choice is never offered there**:
///   All workouts reads the library, which still calls a workout public after moderation has
///   hidden its card, so a choice there could offer a DISCOVER page that is gone. Decided
///   2026-11-11 (`PROFILE_WORKOUTS_PLAN.md`).
/// - `.discover`: someone else's workout. You hold no copy, so DISCOVER's page (Save to Library) is
///   the only one there is.
/// - `.none`: the router cannot open what the row needs, e.g. a router built for DISCOVER, which
///   has no MyDay to open your own workout in.
enum ProfileWorkoutDestination: Equatable {
    case choice
    case workout
    case discover
    case none

    init(
        for workout: ProfileWorkout,
        from source: ProfileWorkoutSource,
        currentUserId: String,
        canOpenWorkout: Bool,
        canOpenDiscover: Bool
    ) {
        switch source {
        case .library:
            self = canOpenWorkout ? .workout : .none
        case .publicCards:
            let ownAndOpenable = workout.createdBy == currentUserId && canOpenWorkout
            switch (ownAndOpenable, canOpenDiscover) {
            case (true, true): self = .choice
            case (true, false): self = .workout
            case (false, true): self = .discover
            case (false, false): self = .none
            }
        }
    }
}
