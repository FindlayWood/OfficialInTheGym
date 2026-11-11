//
//  ReminderPreferencesStoreSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

final class ReminderPreferencesStoreSpy: ReminderPreferencesStore {

    enum Message: Equatable {
        case load
        case save(ReminderPreferences)
    }

    private(set) var receivedMessages: [Message] = []
    private let stored: ReminderPreferences

    init(stored: ReminderPreferences = .default) {
        self.stored = stored
    }

    func load() -> ReminderPreferences {
        receivedMessages.append(.load)
        return stored
    }

    func save(_ preferences: ReminderPreferences) {
        receivedMessages.append(.save(preferences))
    }
}
