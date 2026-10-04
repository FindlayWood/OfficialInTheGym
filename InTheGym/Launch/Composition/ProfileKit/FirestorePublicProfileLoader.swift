//
//  FirestorePublicProfileLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Reads someone's public profile from `Profiles/{uid}`: identity, privacy
/// and counts, every field defaulted the way `profileProjection` defaults it.
/// A missing document is `nil`, which the screen shows as "isn't available".
struct FirestorePublicProfileLoader: PublicProfileLoader {

    func profile(for userId: String) async throws -> PublicProfile? {
        let snapshot = try await Firestore.firestore().document("Profiles/\(userId)").getDocument()
        guard snapshot.exists else { return nil }
        return PublicProfile(
            header: ProfileHeader(
                userId: userId,
                displayName: snapshot.get("displayName") as? String ?? "",
                username: snapshot.get("username") as? String ?? "",
                bio: snapshot.get("bio") as? String ?? "",
                isVerified: snapshot.get("verified") as? Bool == true,
                isElite: snapshot.get("elite") as? Bool == true
            ),
            isPrivate: snapshot.get("isPrivate") as? Bool == true,
            counts: ProfileCounts(
                followers: snapshot.get("followerCount") as? Int ?? 0,
                following: snapshot.get("followingCount") as? Int ?? 0
            )
        )
    }
}
