//
//  CachingUserProfileLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Remembers every profile it has looked up — and every id it found nothing
/// for — for as long as it lives, and only asks `decoratee` for ids it has not
/// seen.
///
/// **A comment thread is mostly the same few people.** Without this, every
/// page and every opened reply thread would re-read the same `Users`
/// documents. Misses are remembered too, or a deleted user's id would be
/// looked up again on every page they appear on. Built once in the composition
/// root, so the cache spans every comment screen in a session.
public final class CachingUserProfileLoader: UserProfileLoader, @unchecked Sendable {

    private let decoratee: UserProfileLoader
    private let lock = NSLock()
    private var cache: [String: DiscoverUserProfile] = [:]
    private var misses: Set<String> = []

    public init(decoratee: UserProfileLoader) {
        self.decoratee = decoratee
    }

    public func profiles(for userIds: Set<String>) async throws -> [String: DiscoverUserProfile] {
        let unknown = withLock { userIds.subtracting(cache.keys).subtracting(misses) }
        if !unknown.isEmpty {
            let loaded = try await decoratee.profiles(for: unknown)
            withLock {
                cache.merge(loaded) { _, new in new }
                misses.formUnion(unknown.subtracting(loaded.keys))
            }
        }
        return withLock { cache.filter { userIds.contains($0.key) } }
    }

    private func withLock<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
