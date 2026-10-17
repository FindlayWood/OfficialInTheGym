//
//  TrialReminderSchedulerSpy.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
@testable import InTheGym

/// Records what the paywall asked of the reminder, and answers with whatever permission the test
/// sets. `permissionResult` is settable so a test can turn notifications on "in Settings" between
/// two calls. Never asserts.
final class TrialReminderSchedulerSpy: TrialReminderScheduling {

    enum Message: Equatable {
        case permission
        case requestPermission
        case schedule(StartedTrial)
    }

    private(set) var receivedMessages: [Message] = []
    var permissionResult: TrialReminderPermission
    var requestResult: Bool

    init(permission: TrialReminderPermission, requestResult: Bool = true) {
        self.permissionResult = permission
        self.requestResult = requestResult
    }

    func permission() async -> TrialReminderPermission {
        receivedMessages.append(.permission)
        return permissionResult
    }

    func requestPermission() async -> Bool {
        receivedMessages.append(.requestPermission)
        return requestResult
    }

    func scheduleReminder(for trial: StartedTrial) {
        receivedMessages.append(.schedule(trial))
    }
}
