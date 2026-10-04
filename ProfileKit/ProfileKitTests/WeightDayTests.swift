//
//  WeightDayTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import XCTest
@testable import ProfileKit

final class WeightDayTests: XCTestCase {

    // The server keys the signup entry in UTC. Keyed by the device's calendar,
    // a log just after local midnight east of GMT would land on yesterday's
    // document, and one late in the evening west of GMT on tomorrow's.
    func test_key_deliversTheUTCDayWhateverTheDeviceZone() {
        let lateEveningInNewYork = ISO8601DateFormatter().date(from: "2026-10-03T23:30:00-05:00")!

        XCTAssertEqual(WeightDay.key(for: lateEveningInNewYork), "2026-10-04")
    }

    func test_entry_deliversTheKeyAndUTCMidnight() {
        let afternoon = ISO8601DateFormatter().date(from: "2026-10-03T14:00:00Z")!

        let sut = WeightDay.entry(kilograms: 80, unit: .kilograms, on: afternoon)

        XCTAssertEqual(sut.id, "2026-10-03")
        XCTAssertEqual(sut.date, ISO8601DateFormatter().date(from: "2026-10-03T00:00:00Z"))
    }
}
