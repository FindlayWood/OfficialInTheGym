//
//  WorkoutHistoryLoaderSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation
@testable import MyDayKit

/// Records which workout's history was asked for and answers with the queued results in order,
/// the last one repeating. Never asserts — the test does.
final class WorkoutHistoryLoaderSpy: WorkoutHistoryLoader, @unchecked Sendable {

    enum Message: Equatable {
        case sessions(templateId: String)
    }

    private(set) var receivedMessages: [Message] = []
    var results: [Result<[CompletedWorkoutSession], Error>] = [.success([])]

    func sessions(forTemplate templateId: String) async throws -> [CompletedWorkoutSession] {
        receivedMessages.append(.sessions(templateId: templateId))
        let result = results.count > 1 ? results.removeFirst() : results[0]
        return try result.get()
    }
}
