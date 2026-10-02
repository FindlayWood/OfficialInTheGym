//
//  WorkoutCopySaverSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every save and answers the saved-check from a fixed value. Never
/// asserts — the test does.
final class WorkoutCopySaverSpy: WorkoutCopySaver, SavedWorkoutCopyChecker, @unchecked Sendable {

    enum Message: Equatable {
        case saveCopy(String)
    }

    private(set) var receivedMessages: [Message] = []
    var alreadySaved = false
    var error: Error?

    func saveCopy(ofWorkout templateId: String) async throws {
        receivedMessages.append(.saveCopy(templateId))
        if let error { throw error }
    }

    func hasSavedCopy(ofWorkout templateId: String) async -> Bool {
        alreadySaved
    }
}
