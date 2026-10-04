//
//  ProfileCountsLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Loads a user's follow counts. `nil` means they have no `Profiles` document
/// yet (before the rollout backfill). The header then shows no counts rather
/// than a "0" that would be a claim, not a fact.
public protocol ProfileCountsLoader {
    func counts(for userId: String) async throws -> ProfileCounts?
}
