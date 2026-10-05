//
//  DiscoverAuthorDirectory.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Combine
import Foundation

/// Who made each workout card, by name. A card carries only `createdBy`, so
/// every list of workouts has to resolve ids to names before it can say "by
/// Alex Morgan".
///
/// **Requests are batched, not made per row.** A list draws ten rows in one
/// pass and each asks for its author as it appears; looking each up on its own
/// would be ten reads where one batched `ProfileNamesReader` query does. Ids
/// asked for in the same pass are collected and flushed together on the next
/// turn of the main actor. An id is only ever requested once — the
/// `CachingUserProfileLoader` underneath remembers it — unless the read
/// failed, when it may be asked for again.
///
/// One per flow, built in the router like `DiscoverModerationStore`, so a name
/// resolved on the home screen is already there in the full list and search.
/// Your own workouts read "You" without a lookup.
@MainActor
final class DiscoverAuthorDirectory: ObservableObject {

    @Published private(set) var names: [String: String] = [:]

    private let loader: UserProfileLoader
    private let currentUserId: String
    private var requested: Set<String> = []
    private var pending: Set<String> = []
    private var isFlushScheduled = false

    init(loader: UserProfileLoader, currentUserId: String) {
        self.loader = loader
        self.currentUserId = currentUserId
    }

    /// The name to show for an author, or nil while unknown — or for a deleted
    /// account, whose row then simply has no byline.
    func name(for userId: String?) -> String? {
        guard let userId else { return nil }
        return userId == currentUserId ? "You" : names[userId]
    }

    func request(_ userId: String?) {
        guard let userId, userId != currentUserId, requested.insert(userId).inserted else { return }
        pending.insert(userId)
        guard !isFlushScheduled else { return }
        isFlushScheduled = true
        Task { await flush() }
    }

    /// Loads everything requested so far in one call. Scheduled by `request`;
    /// tests call it directly.
    func flush() async {
        await Task.yield()
        let ids = pending
        pending = []
        isFlushScheduled = false
        guard !ids.isEmpty else { return }
        do {
            let profiles = try await loader.profiles(for: ids)
            for (id, profile) in profiles {
                names[id] = profile.name
            }
        } catch {
            print("❌ Workout author lookup failed: \(error)")
            requested.subtract(ids)
        }
    }
}
