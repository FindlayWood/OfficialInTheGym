//
//  ProfileHighlightsLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Loads a user's highlights. `nil` means none have been built yet (a new
/// account, or before the rollout's rebuild). A private account's highlights
/// are only readable by approved followers, so the screen asks only when it may
/// show them.
public protocol ProfileHighlightsLoader {
    func highlights(for userId: String) async throws -> ProfileHighlights?
}
