//
//  WorkoutTemplateUploaderSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 13/11/2026.
//

import Foundation
@testable import MyDayKit

final class WorkoutTemplateUploaderSpy: WorkoutTemplateUploading {

    /// The fields a settings change touches. `WorkoutTemplateModel` is not `Equatable`.
    enum Message: Equatable {
        case upload(id: String, isPublic: Bool, tags: [String]?, updatedAt: Date)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func upload(_ template: WorkoutTemplateModel) async throws {
        receivedMessages.append(.upload(
            id: template.id,
            isPublic: template.isPublic,
            tags: template.tags,
            updatedAt: template.updatedAt
        ))
        if let error { throw error }
    }
}
