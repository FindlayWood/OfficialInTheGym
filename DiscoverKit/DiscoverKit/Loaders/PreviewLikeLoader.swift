//
//  PreviewLikeLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer that reports nothing liked.
public final class PreviewLikeLoader: LikeLoader, @unchecked Sendable {
    public init() {}

    public func likedTargets(among targets: [DiscoverLikeTarget]) async throws -> Set<DiscoverLikeTarget> {
        []
    }
}
