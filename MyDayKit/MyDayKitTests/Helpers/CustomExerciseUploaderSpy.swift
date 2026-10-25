//
//  CustomExerciseUploaderSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation
@testable import MyDayKit

final class CustomExerciseUploaderSpy: CustomExerciseUploading {

    enum Message: Equatable {
        case upload(CustomExercise)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func upload(_ exercise: CustomExercise) async throws {
        receivedMessages.append(.upload(exercise))
        if let error { throw error }
    }
}
