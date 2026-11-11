//
//  ProfileReminderKind.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// The reminders the Reminders screen offers, with the words that describe each.
///
/// **Each footer says when the reminder is *not* sent.** That is what makes a reminder safe to
/// turn on: a nudge to check in after checking in is the kind of notification people switch
/// off for good.
public enum ProfileReminderKind: CaseIterable, Hashable, Sendable {
    case checkIn
    case dayRating

    var title: String {
        switch self {
        case .checkIn: return "Morning check-in"
        case .dayRating: return "Rate your day"
        }
    }

    var icon: String {
        switch self {
        case .checkIn: return "sun.max"
        case .dayRating: return "flame"
        }
    }

    var footer: String {
        switch self {
        case .checkIn:
            return "Not sent on a day you've already checked in."
        case .dayRating:
            return "Only on days you've logged training, and not once you've rated it."
        }
    }
}
