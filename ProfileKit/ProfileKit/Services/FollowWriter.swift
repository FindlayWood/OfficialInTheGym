//
//  FollowWriter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Follows someone, returning where that leaves the user: `.following`, or
/// `.requested` for a private account (step 6).
///
/// The adapter picks the status the same way the `Follows` create rule
/// requires it, from the followee's `Profiles.isPrivate`. The rule is what
/// enforces it, so a client cannot follow a private account by claiming
/// `active`. Following someone already followed changes nothing.
public protocol FollowWriter {
    func follow(_ userId: String) async throws -> FollowStatus
}
