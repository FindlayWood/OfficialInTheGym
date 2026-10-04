//
//  UserSearchLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Finds people whose @username or display name **starts with** `query`.
/// `query` arrives already normalised: trimmed, lowercased, no leading "@".
/// A prefix match, not a substring one, because Firestore can only answer
/// prefixes, and "start of a name" is also what people type.
public protocol UserSearchLoader {
    func search(_ query: String, limit: Int) async throws -> [ProfileSummary]
}
