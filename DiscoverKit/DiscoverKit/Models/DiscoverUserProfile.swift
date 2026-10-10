//
//  DiscoverUserProfile.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Who wrote a comment, as much as a comment row shows. Resolved from the
/// author's id at display time rather than copied onto the comment, so a
/// changed display name is current everywhere.
public struct DiscoverUserProfile: Identifiable, Hashable, Sendable {
    public let userId: String
    public let username: String
    public let displayName: String

    public var id: String { userId }

    public init(userId: String, username: String, displayName: String) {
        self.userId = userId
        self.username = username
        self.displayName = displayName
    }

    var name: String {
        displayName.isEmpty ? username : displayName
    }

    var initial: String {
        name.first.map { String($0).uppercased() } ?? "?"
    }
}
