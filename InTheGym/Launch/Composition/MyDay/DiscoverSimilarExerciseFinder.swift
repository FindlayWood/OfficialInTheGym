//
//  DiscoverSimilarExerciseFinder.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation
import MyDayKit

/// Answers MyDayKit's `SimilarExerciseFinder` with DISCOVER's
/// `DiscoverExerciseMatcher` — matching inside words and forgiving one typo —
/// so the custom exercise form's "did you mean…?" and DISCOVER's exercise
/// search are one rule, not two that drift.
struct DiscoverSimilarExerciseFinder: SimilarExerciseFinder {

    func exercises(named name: String, in exercises: [Exercise], limit: Int) -> [Exercise] {
        DiscoverExerciseMatcher.search(name, in: exercises, name: \.name, limit: limit)
    }
}
