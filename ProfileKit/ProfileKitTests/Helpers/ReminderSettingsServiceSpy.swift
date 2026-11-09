//
//  ReminderSettingsServiceSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import ProfileKit

@MainActor
final class ReminderSettingsServiceSpy: ReminderSettingsService {

    enum Message: Equatable {
        case load
        case save(ProfileReminderSettings)
        case permission
        case requestPermission
    }

    private(set) var receivedMessages: [Message] = []
    private let stored: ProfileReminderSettings
    private var status: ProfileReminderPermission
    private let grants: Bool

    init(stored: ProfileReminderSettings, status: ProfileReminderPermission, grants: Bool) {
        self.stored = stored
        self.status = status
        self.grants = grants
    }

    func loadSettings() -> ProfileReminderSettings {
        receivedMessages.append(.load)
        return stored
    }

    func save(_ settings: ProfileReminderSettings) {
        receivedMessages.append(.save(settings))
    }

    func permission() async -> ProfileReminderPermission {
        receivedMessages.append(.permission)
        return status
    }

    func requestPermission() async -> Bool {
        receivedMessages.append(.requestPermission)
        status = grants ? .allowed : .denied
        return grants
    }
}
