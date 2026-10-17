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
    /// Where permission stands. Never prompts.
    func permission() async -> TrialReminderPermission
    /// Shows the system prompt if the user has never been asked; `true` if reminders can be delivered.
    func requestPermission() async -> Bool
    func scheduleReminder(for trial: StartedTrial)
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
///
/// **Emulator builds fire it 60 seconds after scheduling** (`fireDate`), so the whole path —
/// paywall, reminder screen, system prompt, notification — can be tested in a minute instead of
/// thirteen days. Compiled only with `-D EMULATOR`, the same switch as `EmulatorPurchaseManager`,
/// so no build that can ship gets it. The screens still show the real dates.
final class LocalNotificationTrialReminder: TrialReminderScheduling {

    static let identifier = "pro-trial-ending"

    private let center: UNUserNotificationCenter
    private let fireDate: (StartedTrial) -> Date

    init(center: UNUserNotificationCenter = .current(), fireDate: @escaping (StartedTrial) -> Date = LocalNotificationTrialReminder.defaultFireDate) {
        self.center = center
        self.fireDate = fireDate
    }

    static var defaultFireDate: (StartedTrial) -> Date {
        #if EMULATOR
        { _ in Date().addingTimeInterval(60) }
        #else
        { $0.remindsAt }
        #endif
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

    func permission() async -> TrialReminderPermission {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: return .allowed
        case .notDetermined: return .notAsked
        case .denied: return .denied
        @unknown default: return .denied
        }
    }

    func scheduleReminder(for trial: StartedTrial) {
        let fireDate = fireDate(trial)
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your INTHEGYM pro trial ends tomorrow"
        content.body = "You'll be charged \(trial.priceText) unless you cancel before then. You can cancel any time in Settings → Subscriptions."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: Self.identifier, content: content, trigger: trigger)
        center.add(request) { error in
            if let error {
                print("❌ Trial reminder not scheduled: \(error)")
            }
        }
    }
}
