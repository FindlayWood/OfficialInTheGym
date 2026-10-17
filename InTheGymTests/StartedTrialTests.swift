//
//  StartedTrialTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import XCTest
@testable import InTheGym

final class StartedTrialTests: XCTestCase {

    func test_endsAt_deliversStartPlusTrialDays() {
        let sut = StartedTrial(startedAt: fixedDate, days: 14, priceText: "£59.99 / year", calendar: calendar)

        XCTAssertEqual(sut.endsAt, calendar.date(byAdding: .day, value: 14, to: fixedDate))
    }

    // The reminder is promised for the day before the charge. A day out either way is the one
    // mistake this screen cannot make — the reminder would arrive after the money had gone.
    func test_remindsAt_deliversOneDayBeforeTheTrialEnds() {
        let sut = StartedTrial(startedAt: fixedDate, days: 14, priceText: "£59.99 / year", calendar: calendar)

        XCTAssertEqual(sut.remindsAt, calendar.date(byAdding: .day, value: 13, to: fixedDate))
    }

    // MARK: - Helpers

    private var calendar: Calendar { .current }

    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_791_000_000)
    }
}
