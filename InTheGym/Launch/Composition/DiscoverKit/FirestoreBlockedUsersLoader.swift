//
//  FirestoreBlockedUsersLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// The signed-in user's blocks: `Users/{uid}/BlockedUsers/{blockedUid}`, one
/// document per blocked user, id'd by them.
struct FirestoreBlockedUsersLoader: BlockedUsersLoader {

    let userId: String

    func blockedUserIds() async throws -> Set<String> {
        let snapshot = try await Firestore.firestore()
            .collection(DiscoverBlockPath.blockedUsers(of: userId))
            .getDocuments()
        return Set(snapshot.documents.map(\.documentID))
    }
}
