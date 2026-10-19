//
//  ProfileJoinedMonthTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 19/10/2026.
//

import XCTest
@testable import ProfileKit

final class ProfileJoinedMonthTests: XCTestCase {

    func test_text_deliversMonthAndYear() {
        let sut = ProfileJoinedMonth.text(for: utcDate("2026-10-01T00:00:00Z"), locale: britishEnglish)

        XCTAssertEqual(sut, "Joined Oct 2026")
    }

    // The server stores midnight UTC on the first of the month. Read in a zone
    // west of GMT that is still the 30th, so a device-zone formatter would print
    // the month before for every account.
    func test_text_readsTheMonthInUTCNotTheDeviceZone() {
        let sut = ProfileJoinedMonth.text(for: utcDate("2026-11-01T00:00:00Z"), locale: britishEnglish)

        XCTAssertEqual(sut, "Joined Nov 2026")
    }

    // MARK: - Helpers

    private var britishEnglish: Locale { Locale(identifier: "en_GB") }

    private func utcDate(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string)!
    }
}
