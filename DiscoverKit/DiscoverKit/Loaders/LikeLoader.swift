//
//  LikeLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Which of `targets` the signed-in user has liked.
public protocol LikeLoader {
    func likedTargets(among targets: [DiscoverLikeTarget]) async throws -> Set<DiscoverLikeTarget>
}
