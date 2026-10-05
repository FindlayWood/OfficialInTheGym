//
//  DiscoverSearchScope.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// What a search looks through: everything, or one kind.
///
/// **Narrowing changes the query, not just the screen.** A single kind is
/// searched alone and asks for more results (`limit`), so filtering to
/// workouts both saves two queries and shows workouts past the first ten
/// rather than hiding the other sections over the same short list.
enum DiscoverSearchScope: CaseIterable, Hashable {
    case all
    case people
    case workouts
    case exercises

    var title: String {
        switch self {
        case .all: "All"
        case .people: "People"
        case .workouts: "Workouts"
        case .exercises: "Exercises"
        }
    }

    /// Per kind. Ten under All, where three full sections of twenty would bury
    /// the third; twenty-five once a single kind has the screen to itself.
    var limit: Int {
        self == .all ? 10 : 25
    }

    var includesPeople: Bool { self == .all || self == .people }
    var includesWorkouts: Bool { self == .all || self == .workouts }
    var includesExercises: Bool { self == .all || self == .exercises }
}
