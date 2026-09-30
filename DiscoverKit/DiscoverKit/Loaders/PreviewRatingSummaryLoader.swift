//
//  PreviewRatingSummaryLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer. Ships in the framework, as the card loaders' do.
public final class PreviewRatingSummaryLoader: RatingSummaryLoader, @unchecked Sendable {
    let summary: RatingSummary

    public init(summary: RatingSummary = RatingSummary(count: 12, sum: 89)) {
        self.summary = summary
    }

    public func summary(for subject: DiscoverSubject) async throws -> RatingSummary {
        summary
    }
}
