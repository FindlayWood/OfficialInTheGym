//
//  SimilarExerciseFinder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Finds exercises whose name is close to the one being typed, for the custom
/// exercise form's "did you mean…?".
///
/// **One matcher, not a second one written here.** DISCOVER already matches
/// exercise names inside words and forgiving a typo (`DiscoverExerciseMatcher`);
/// MyDayKit cannot import DiscoverKit, so it declares what it needs and the
/// composition root answers with that matcher — as `TagNormalizer` does for
/// tags the other way round.
public protocol SimilarExerciseFinder {
    func exercises(named name: String, in exercises: [Exercise], limit: Int) -> [Exercise]
}

/// Finds nothing, for previews and anything built without a matcher.
public struct EmptySimilarExerciseFinder: SimilarExerciseFinder {
    public init() {}

    public func exercises(named name: String, in exercises: [Exercise], limit: Int) -> [Exercise] {
        []
    }
}
