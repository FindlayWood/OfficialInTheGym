//
//  FirestoreProfileSummaryLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit

/// Names for ProfileKit's follow lists, through the shared `ProfileNamesReader`.
struct FirestoreProfileSummaryLoader: ProfileSummaryLoader {

    var reader = ProfileNamesReader()

    func summaries(for userIds: Set<String>) async throws -> [String: ProfileSummary] {
        try await reader.names(for: userIds).mapValues {
            ProfileSummary(userId: $0.userId, username: $0.username, displayName: $0.displayName)
        }
    }
}
