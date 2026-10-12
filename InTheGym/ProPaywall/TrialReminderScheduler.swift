//
//  TrialReminderScheduler.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import UserNotifications

/// Schedules the "your trial ends tomorrow" reminder the paywall offers.
protocol TrialReminderScheduling {
    /// Whether a reminder could be delivered, asking for permission if it has never been asked.
    /// `false` means the user has turned notifications off for the app.
    func requestPermission() async -> Bool
    /// Whether the user has turned notifications off for the app. Never prompts.
    func isDenied() async -> Bool
    func scheduleReminder(trialEndsAt endDate: Date, price: String)
}

/// A local notification, one day before the trial converts.
///
/// **Local, not a push from the server.** The trial end is fixed the moment the purchase completes
/// — Apple bills exactly one trial length after it — so the device already knows the date and
/// nothing else needs to. It fires at the same time of day the trial was started, a day early,
/// which leaves a whole day to cancel; a reminder in the last hour would be a reminder too late.
///
/// One identifier, so starting a second trial (another account on the device) replaces the first
/// reminder rather than stacking two.
final class LocalNotificationTrialReminder: TrialReminderScheduling {

    static let identifier = "pro-trial-ending"

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestPermission() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func isDenied() async -> Bool {
        await center.notificationSettings().authorizationStatus == .denied
    }

    func scheduleReminder(trialEndsAt endDate: Date, price: String) {
        let fireDate = endDate.addingTimeInterval(-24 * 60 * 60)
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your INTHEGYM pro trial ends tomorrow"
        content.body = "You'll be charged \(price) unless you cancel before then. You can cancel any time in Settings → Subscriptions."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifier, content: content, trigger: trigger)
        center.add(request) { error in
            if let error {
                print("❌ Trial reminder not scheduled: \(error)")
            }
        }
    }
}
