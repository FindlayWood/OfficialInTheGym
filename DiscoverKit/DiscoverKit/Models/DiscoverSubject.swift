//
//  DiscoverSubject.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The thing a rating, comment, like or tag vote is about — an exercise, a
/// workout or a clip — as the pure identity of kind and id.
///
/// **It knows no Firestore path.** The paths it stands for live in the
/// composition root (`DiscoverSubject+Firestore.swift`), the one place they are
/// written down; the framework holds no infrastructure, and a path built at a
/// call site is the shape AccountCreationKit moved away from.
public enum DiscoverSubject: Hashable, Sendable {
    case exercise(id: String)
    case workout(id: String)
    case clip(id: String)

    public var id: String {
        switch self {
        case .exercise(let id), .workout(let id), .clip(let id):
            return id
        }
    }

    /// Clips are comments and likes only — a clip is a user doing an exercise,
    /// not something to score.
    public var isRateable: Bool {
        switch self {
        case .exercise, .workout:
            return true
        case .clip:
            return false
        }
    }
}
