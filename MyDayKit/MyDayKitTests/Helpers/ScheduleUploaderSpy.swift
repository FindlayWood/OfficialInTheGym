//
//  ScheduleUploaderSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation
@testable import MyDayKit

final class ScheduleUploaderSpy: ScheduleUploading {

    enum Message: Equatable {
        case upload(Schedule)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func upload(_ schedule: Schedule) async throws {
        receivedMessages.append(.upload(schedule))
        if let error { throw error }
    }
}
