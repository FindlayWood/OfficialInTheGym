//
//  UserNotificationReminderPermission.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit
import UserNotifications

/// Notification permission for reminders. Asked only when the user turns a reminder on — see
/// `ReminderSettingsViewModel` — never at launch.
///
/// The same questions `LocalNotificationTrialReminder` asks, in MyDayKit's terms. One
/// permission, two features asking it in context.
final class UserNotificationReminderPermission: ReminderPermissionAsking, @unchecked Sendable {

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func status() async -> ReminderPermissionStatus {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: return .allowed
        case .notDetermined: return .notAsked
        case .denied: return .denied
        @unknown default: return .denied
        }
    }

    func request() async -> Bool {
        switch await status() {
        case .allowed:
            return true
        case .notAsked:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            return false
        }
    }
}
