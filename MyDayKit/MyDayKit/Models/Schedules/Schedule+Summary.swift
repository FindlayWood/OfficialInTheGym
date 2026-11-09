//
//  Schedule+Summary.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

extension Schedule {

    /// When this falls, and a sport's usual time, which is part of what was scheduled: "Every Tue,
    /// Thu · 1h 30m". A workout has no usual time, so it is the recurrence alone.
    var summary: String {
        guard case .sport(_, let duration) = item else {
            return recurrence.summary
        }
        return "\(recurrence.summary) · \(SportSessionSummary.formatted(seconds: duration))"
    }
}
