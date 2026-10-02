//
//  PreviewRatingWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer that accepts every rating and stores nothing.
public final class PreviewRatingWriter: RatingWriter, @unchecked Sendable {
    public init() {}

    public func setRating(_ rating: Int, for subject: DiscoverSubject) async throws {}
}
