//
//  DiscoverLikeTarget.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// What a like is on: a comment (on any subject), or a clip. Exercises and
/// workouts are rated, not liked. `@frozen` for the reason `DiscoverSubject` is.
@frozen
public enum DiscoverLikeTarget: Hashable, Sendable {
    case comment(commentId: String, subject: DiscoverSubject)
    case clip(id: String)
}
