//
//  ACWRTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 09/08/2026.
//

import XCTest
@testable import StatsKit

final class ACWRTests: XCTestCase {

    func test_rolling_deliversNoRatioOnEmptyLoad() {
        let sut = ACWR.rolling(loadByDay: [:], endingOn: fixedDate)

        XCTAssertNil(sut.ratio)
        XCTAssertEqual(sut.zone, .insufficient)
        XCTAssertEqual(sut.formattedRatio, "—")
    }

    func test_rolling_deliversRatioOfOneOnSteadyLoad() {
        let sut = ACWR.rolling(loadByDay: load(100, forLastDays: 28), endingOn: fixedDate)

        XCTAssertEqual(sut.acute, 100, accuracy: 0.001)
        XCTAssertEqual(sut.chronic, 100, accuracy: 0.001)
        XCTAssertEqual(sut.ratio ?? 0, 1.0, accuracy: 0.001)
        XCTAssertEqual(sut.zone, .optimal)
    }

    func test_rolling_averagesOverWindowLengthNotOverTrainedDays() {
        // One day of work in an otherwise empty month. Averaged over the days
        // that had training this would read 700; averaged over the window — the
        // behaviour a deload depends on — it reads 100 acute and 25 chronic.
        let sut = ACWR.rolling(
            loadByDay: [StatsDay.key(for: fixedDate): 700],
            endingOn: fixedDate
        )

        XCTAssertEqual(sut.acute, 100, accuracy: 0.001)
        XCTAssertEqual(sut.chronic, 25, accuracy: 0.001)
        XCTAssertEqual(sut.ratio ?? 0, 4.0, accuracy: 0.001)
        XCTAssertEqual(sut.zone, .danger)
    }

    func test_rolling_deliversLowZoneWhenAcuteWindowIsEmptyButChronicIsNot() {
        // A week completely off, on top of three weeks of training. The acute
        // window has to see those rest days as zero or the deload never shows.
        var loads = load(100, forLastDays: 28)
        for offset in 0..<7 {
            loads[StatsDay.key(daysAgo: offset, from: fixedDate)] = 0
        }

        let sut = ACWR.rolling(loadByDay: loads, endingOn: fixedDate)

        XCTAssertEqual(sut.acute, 0, accuracy: 0.001)
        XCTAssertEqual(sut.ratio ?? -1, 0, accuracy: 0.001)
        XCTAssertEqual(sut.zone, .low)
    }

    func test_rolling_ignoresLoadOutsideTheChronicWindow() {
        // Day 28 is one day past the chronic window and must not count.
        let loads = [StatsDay.key(daysAgo: 28, from: fixedDate): 1000.0]

        let sut = ACWR.rolling(loadByDay: loads, endingOn: fixedDate)

        XCTAssertEqual(sut.chronic, 0, accuracy: 0.001)
        XCTAssertNil(sut.ratio)
    }

    func test_zone_mapsRatioToZoneAtBoundaries() {
        let samples: [(ratio: Double, expected: ACWR.Zone)] = [
            (0.0,  .low),
            (0.79, .low),
            (0.8,  .optimal),
            (1.29, .optimal),
            (1.3,  .caution),
            (1.49, .caution),
            (1.5,  .danger),
            (3.0,  .danger)
        ]

        samples.forEach { sample in
            XCTAssertEqual(
                ACWR.Zone(ratio: sample.ratio),
                sample.expected,
                "expected \(sample.expected) for ratio \(sample.ratio)"
            )
        }
    }

    // MARK: - Helpers

    /// Fixed so the suite does not depend on the day it runs on.
    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_760_000_000)
    }

    private func load(_ value: Double, forLastDays days: Int) -> [String: Double] {
        Dictionary(
            uniqueKeysWithValues: (0..<days).map {
                (StatsDay.key(daysAgo: $0, from: fixedDate), value)
            }
        )
    }
}
