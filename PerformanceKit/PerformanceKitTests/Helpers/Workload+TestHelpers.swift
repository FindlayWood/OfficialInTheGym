//
//  Workload+TestHelpers.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

extension Workload {

    /// A workload of `total` load, all in the base `workload` field, ending
    /// `daysAgo` whole days before `Date.fixed`.
    static func make(total: Int, daysAgo: Int = 0, id: String = UUID().uuidString) -> Workload {
        Workload(id: id, endTime: Date.fixed.addingTimeInterval(-Double(daysAgo) * 86_400), rpe: 5, timeToComplete: 3600, workload: total)
    }
}

extension Calendar {

    /// Gregorian in UTC, so day boundaries in tests do not move with the
    /// machine's time zone.
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
}
