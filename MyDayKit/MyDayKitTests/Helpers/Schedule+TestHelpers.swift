//
//  Schedule+TestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation
@testable import MyDayKit

extension Schedule {

    /// Every Tuesday from Monday 9 November 2026, unless a test says otherwise.
    static func fixture(
        id: String = "schedule",
        recurrence: ScheduleRecurrence = .weekly(weekdays: [.tuesday], start: .fixture("2026-11-09")),
        createdAt: Date = Date(timeIntervalSince1970: 1_800_000_000),
        updatedAt: Date = Date(timeIntervalSince1970: 1_800_000_000),
        stoppedAt: Date? = nil
    ) -> Schedule {
        Schedule(
            id: id,
            item: .workout(templateId: "template"),
            recurrence: recurrence,
            createdAt: createdAt,
            updatedAt: updatedAt,
            stoppedAt: stoppedAt
        )
    }
}
