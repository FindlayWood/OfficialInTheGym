//
//  ExerciseCatalogueLoaderSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import Foundation
@testable import DiscoverKit

/// Counts catalogue loads and answers each from the next queued result, the
/// last repeating. Never asserts — the test does.
final class ExerciseCatalogueLoaderSpy: ExerciseCatalogueLoader, @unchecked Sendable {

    enum Message: Equatable {
        case allExercises
    }

    private(set) var receivedMessages: [Message] = []
    var results: [Result<[DiscoverExerciseCard], Error>] = [.success([])]

    func allExercises() async throws -> [DiscoverExerciseCard] {
        receivedMessages.append(.allExercises)
        let result = results.count > 1 ? results.removeFirst() : results[0]
        return try result.get()
    }
}
