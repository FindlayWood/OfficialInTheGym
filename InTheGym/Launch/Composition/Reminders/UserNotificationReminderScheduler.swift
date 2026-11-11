//
//  UserNotificationReminderScheduler.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit
import UserNotifications

/// MyDay's reminders as local notifications. See `ReminderPlanner` for what is planned and why.
///
/// **It only ever touches identifiers under `ReminderKind.identifierPrefix`.** The trial reminder
/// (`LocalNotificationTrialReminder`) shares the notification centre, and a re-plan that removed
/// everything pending would cancel the one notification the paywall promised.
///
/// Delivered notifications are left in Notification Centre, except when the plan is empty —
/// signing out, or every reminder turned off — when ours are cleared too, so nobody finds
/// another account's nudge on the lock screen.
final class UserNotificationReminderScheduler: ReminderScheduling, @unchecked Sendable {

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func replaceReminders(with reminders: [PlannedReminder]) async {
        let wanted = Set(reminders.map(\.identifier))
        let pending = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(ReminderKind.identifierPrefix) && !wanted.contains($0) }
        center.removePendingNotificationRequests(withIdentifiers: pending)

        if reminders.isEmpty {
            let delivered = await center.deliveredNotifications()
                .map(\.request.identifier)
                .filter { $0.hasPrefix(ReminderKind.identifierPrefix) }
            center.removeDeliveredNotifications(withIdentifiers: delivered)
        }

        // Adding an identifier that is already pending replaces it, so an unchanged plan
        // rewrites the same requests rather than stacking copies.
        for reminder in reminders {
            do {
                try await center.add(request(for: reminder))
            } catch {
                print("❌ Reminder not scheduled \(reminder.identifier): \(error)")
            }
        }
    }

    private func request(for reminder: PlannedReminder) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.userInfo = [ReminderKind.userInfoKey: reminder.kind.rawValue]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger)
    }
}
