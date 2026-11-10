//
//  InjuryTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import XCTest
@testable import MyDayKit

final class InjuryTests: XCTestCase {

    // MARK: - Title

    func test_title_deliversSideAndRegion() {
        XCTAssertEqual(Injury.fixture(region: .hamstring, side: .left).title, "Left hamstring")
        XCTAssertEqual(Injury.fixture(region: .knee, side: .both).title, "Both knees")
        XCTAssertEqual(Injury.fixture(region: .foot, side: .both).title, "Both feet")
    }

    // A back has no side. Storing one would title it "Left lower back".
    func test_init_dropsTheSideForARegionWithoutOne() {
        let sut = Injury.fixture(region: .lowerBack, side: .left)

        XCTAssertNil(sut.side)
        XCTAssertEqual(sut.title, "Lower back")
    }

    // MARK: - Active

    func test_isActive_deliversTrueFromItsStartUntilCleared() {
        let sut = Injury.fixture(startedOn: "2026-11-08", resolvedOn: "2026-11-12")

        XCTAssertFalse(sut.isActive(on: .fixture("2026-11-07")))
        XCTAssertTrue(sut.isActive(on: .fixture("2026-11-08")))
        XCTAssertTrue(sut.isActive(on: .fixture("2026-11-11")))
        XCTAssertFalse(sut.isActive(on: .fixture("2026-11-12")))
    }

    func test_isActive_deliversFalseOnceRemoved() {
        let sut = Injury.fixture(removedAt: Date())

        XCTAssertFalse(sut.isActive(on: .fixture("2026-11-10")))
    }

    // MARK: - Check-ins

    func test_latestCheckIn_deliversTheMostRecentDayBeforeTheOneAsked() {
        let sut = Injury.fixture(checkIns: [
            "2026-11-08": .fixture(pain: 6),
            "2026-11-09": .fixture(pain: 4),
            "2026-11-10": .fixture(pain: 2)
        ])

        XCTAssertEqual(sut.latestCheckIn(before: .fixture("2026-11-10"))?.pain, 4)
        XCTAssertNil(sut.latestCheckIn(before: .fixture("2026-11-08")))
    }

    func test_checkIn_clampsPainToTheScale() {
        XCTAssertEqual(InjuryCheckIn.fixture(pain: 14).pain, 10)
        XCTAssertEqual(InjuryCheckIn.fixture(pain: -2).pain, 0)
    }

    func test_dayNumber_countsTheStartAsDayOne() {
        let sut = Injury.fixture(startedOn: "2026-11-08")

        XCTAssertEqual(sut.dayNumber(on: .fixture("2026-11-08")), 1)
        XCTAssertEqual(sut.dayNumber(on: .fixture("2026-11-10")), 3)
    }

    // MARK: - Storage

    // Stored on disk and in Firestore. A day must come back as the same day, not an instant.
    func test_codable_roundTripsAnInjuryWithCheckIns() throws {
        let sut = Injury.fixture(resolvedOn: "2026-11-20", checkIns: ["2026-11-10": .fixture()])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try decoder.decode(Injury.self, from: encoder.encode(sut))

        XCTAssertEqual(decoded, sut)
    }
}
