//
//  FirestoreMyTagVotesLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// The signed-in user's tags on a subject. No document is no tags.
struct FirestoreMyTagVotesLoader: MyTagVotesLoader {

    let userId: String

    func myTags(on subject: DiscoverSubject) async throws -> [String] {
        let snapshot = try await Firestore.firestore().document(subject.tagVotePath(userId: userId)).getDocument()
        return snapshot.get("tags") as? [String] ?? []
    }
}
