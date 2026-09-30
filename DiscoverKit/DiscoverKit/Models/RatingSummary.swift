//
//  RatingSummary.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// A subject's ratings as the card stores them: a count and a sum, never an
/// average.
///
/// **`average` is the one place the displayed average is worked out.** The
/// server stores `ratingSum` / `ratingCount` so no rounding is ever baked in,
/// and its `score` is a Bayesian ordering value that must never be shown — one
/// rating of 10 scores 6.25 there, which would be a lie on screen.
public struct RatingSummary: Equatable, Sendable {
    public let count: Int
    public let sum: Int

    public init(count: Int, sum: Int) {
        self.count = count
        self.sum = sum
    }

    public static let empty = RatingSummary(count: 0, sum: 0)

    /// `nil` with no ratings — an absence, never drawn as a 0.
    var average: Double? {
        count > 0 ? Double(sum) / Double(count) : nil
    }

    /// `7.4`, or `—` with no ratings.
    var formattedAverage: String {
        average.map { String(format: "%.1f", $0) } ?? "—"
    }

    /// The summary as it will read once the server has recounted a user's
    /// rating — what the screen shows straight after rating, rather than
    /// holding the old average until the Cloud Function catches up.
    ///
    /// A rating document is one per user, so re-rating **replaces** the old
    /// value: the count only moves on a first rating.
    func replacingRating(_ old: Int?, with new: Int) -> RatingSummary {
        guard let old else {
            return RatingSummary(count: count + 1, sum: sum + new)
        }
        return RatingSummary(count: count, sum: sum - old + new)
    }
}
