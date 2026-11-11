//
//  ReminderSchedulerSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

final class ReminderSchedulerSpy: ReminderScheduling, @unchecked Sendable {

    enum Message: Equatable {
        case replace([String])
    }

    private(set) var receivedMessages: [Message] = []

    func replaceReminders(with reminders: [PlannedReminder]) async {
        receivedMessages.append(.replace(reminders.map(\.identifier)))
    }
}
