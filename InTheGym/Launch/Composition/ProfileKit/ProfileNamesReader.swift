//
//  ProfileNamesReader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import Foundation

/// Reads name and @username for a set of users from `Profiles/{uid}`, thirty
/// ids per query, the most one Firestore `in` accepts, with the batches in
/// parallel.
///
/// **The one place that query is written.** DISCOVER's author names
/// (`FirestoreUserProfileLoader`) and ProfileKit's follow lists
/// (`FirestoreProfileSummaryLoader`) both need it. Each adapter only maps the
/// result into its own framework's model.
struct ProfileNamesReader {

    struct Name {
        let userId: String
        let username: String
        let displayName: String
    }

    static let batchSize = 30

    func names(for userIds: Set<String>) async throws -> [String: Name] {
        let ids = Array(userIds)
        let batches = stride(from: 0, to: ids.count, by: Self.batchSize).map {
            Array(ids[$0..<min($0 + Self.batchSize, ids.count)])
        }
        let profiles = Firestore.firestore().collection("Profiles")

        return try await withThrowingTaskGroup(of: [Name].self) { group in
            for batch in batches {
                group.addTask {
                    let snapshot = try await profiles.whereField(FieldPath.documentID(), in: batch).getDocuments()
                    return snapshot.documents.map { document in
                        Name(
                            userId: document.documentID,
                            username: document.get("username") as? String ?? "",
                            displayName: document.get("displayName") as? String ?? ""
                        )
                    }
                }
            }
            var names: [String: Name] = [:]
            for try await batch in group {
                for name in batch { names[name.userId] = name }
            }
            return names
        }
    }
}
