//
//  CatalogueExerciseSearchLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 10/10/2026.
//

import Foundation

/// Exercise search on the device: loads the catalogue once through
/// `ExerciseCatalogueLoader`, keeps it, and answers every search from it with
/// `DiscoverExerciseMatcher` — matches inside a word and one-typo matches,
/// neither of which a Firestore query can do.
///
/// **The catalogue is kept for as long as this lives** — one per router, so a
/// session's searches cost one read of the catalogue, not one per keystroke. A
/// failed load is not kept, so the next search tries again.
public final class CatalogueExerciseSearchLoader: ExerciseSearchLoader, @unchecked Sendable {

    private let catalogue: ExerciseCatalogueLoader
    private let lock = NSLock()
    private var cached: [DiscoverExerciseCard]?

    public init(catalogue: ExerciseCatalogueLoader) {
        self.catalogue = catalogue
    }

    public func exercises(matching query: String, limit: Int) async throws -> [DiscoverExerciseCard] {
        DiscoverExerciseMatcher.search(query, in: try await catalogueCards(), limit: limit)
    }

    private func catalogueCards() async throws -> [DiscoverExerciseCard] {
        if let cached = withLock({ cached }) { return cached }
        let loaded = try await catalogue.allExercises()
        withLock { cached = loaded }
        return loaded
    }

    private func withLock<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
