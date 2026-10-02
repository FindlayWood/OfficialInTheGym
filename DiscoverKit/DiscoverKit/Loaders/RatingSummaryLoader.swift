//
//  RatingSummaryLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Reads a subject's current rating counts off its card.
///
/// The card a detail screen was opened from is a snapshot of when its list
/// loaded; this refreshes it on appear, so an average does not stay behind a
/// rating the Cloud Function has since counted.
public protocol RatingSummaryLoader {
    func summary(for subject: DiscoverSubject) async throws -> RatingSummary
}
