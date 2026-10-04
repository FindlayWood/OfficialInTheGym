//
//  ProfileSummary.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Just enough of someone to draw them in a list: name and @username, from
/// `Profiles/{uid}`. Photos load separately, row by row, through
/// `ProfilePhotoLoader`.
public struct ProfileSummary: Equatable, Sendable {
    public let userId: String
    public let username: String
    public let displayName: String

    public init(userId: String, username: String, displayName: String) {
        self.userId = userId
        self.username = username
        self.displayName = displayName
    }
}
