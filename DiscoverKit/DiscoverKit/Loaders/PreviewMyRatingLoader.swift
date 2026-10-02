//
//  PreviewMyRatingLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer. Ships in the framework, as the card loaders' do.
public final class PreviewMyRatingLoader: MyRatingLoader, @unchecked Sendable {
    let rating: Int?

    public init(rating: Int? = nil) {
        self.rating = rating
    }

    public func myRating(for subject: DiscoverSubject) async throws -> Int? {
        rating
    }
}
