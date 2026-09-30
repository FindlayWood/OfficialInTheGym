//
//  DiscoverWorkoutCard+RatingSummary.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

extension DiscoverWorkoutCard {

    /// The card's counts as a summary. Absent counts are a card nobody has
    /// rated yet, not a failure.
    var ratingSummary: RatingSummary {
        RatingSummary(count: ratingCount ?? 0, sum: ratingSum ?? 0)
    }
}
