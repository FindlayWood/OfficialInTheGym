//
//  ProfileReminderPermission.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Whether the system will show the app's notifications, as the Reminders screen needs to know it.
public enum ProfileReminderPermission: Equatable, Sendable {
    case allowed
    /// Never asked. Turning a reminder on asks.
    case notAsked
    /// Turned off in Settings; only the Settings app can turn it back on.
    case denied
}
