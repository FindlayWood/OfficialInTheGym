//
//  ProfileSummaryLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Loads names for a set of users at once, keyed by id. A user with no profile
/// is simply missing from the result. Their row then reads as an unknown user
/// rather than failing the whole list.
public protocol ProfileSummaryLoader {
    func summaries(for userIds: Set<String>) async throws -> [String: ProfileSummary]
}
