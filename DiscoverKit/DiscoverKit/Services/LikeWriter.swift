//
//  LikeWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Likes or unlikes a target as the signed-in user. One like per user per
/// target, so liking twice is the same as liking once.
public protocol LikeWriter {
    func setLiked(_ liked: Bool, for target: DiscoverLikeTarget) async throws
}
