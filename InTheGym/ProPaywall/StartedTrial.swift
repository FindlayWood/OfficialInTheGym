//
//  StartedTrial.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// A free trial: when it ends, when the reminder fires, and what it then costs.
///
/// **The one definition of those two dates.** The paywall's timeline shows them before the purchase,
/// the reminder screen and success screen repeat them after it, and `LocalNotificationTrialReminder`
/// fires on one of them — four places that each worked a date out for themselves would sooner or
/// later disagree by a day, on the one screen where a day matters. The trial ends exactly `days`
/// after it starts (Apple bills then), and the reminder is a calendar day before that, at the same
/// time of day, which leaves a whole day to cancel.
struct StartedTrial: Equatable {

    let endsAt: Date
    /// The price charged when the trial ends — "£59.99 / year".
    let priceText: String

    init(startedAt: Date, days: Int, priceText: String, calendar: Calendar = .current) {
        self.endsAt = calendar.date(byAdding: .day, value: days, to: startedAt) ?? startedAt
        self.priceText = priceText
    }

    var remindsAt: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: endsAt) ?? endsAt
    }

    /// "Saturday 24 October" — every trial date the user is shown.
    static func display(_ date: Date) -> String {
        formatter.string(from: date)
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        return formatter
    }()
}
