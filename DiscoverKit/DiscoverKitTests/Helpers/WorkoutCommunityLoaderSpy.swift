//
//  WorkoutCommunityLoaderSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation
@testable import DiscoverKit

final class WorkoutCommunityLoaderSpy: WorkoutCommunityLoader, @unchecked Sendable {

    enum Message: Equatable {
        case community(String)
    }

    private(set) var receivedMessages: [Message] = []
    var result: Result<DiscoverWorkoutCommunity?, Error> = .success(nil)

    func community(ofWorkout templateId: String) async throws -> DiscoverWorkoutCommunity? {
        receivedMessages.append(.community(templateId))
        return try result.get()
    }
}
