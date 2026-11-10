//
//  ReadinessSeriesTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import XCTest
@testable import StatsKit

final class ReadinessSeriesTests: XCTestCase {

    // A missed check-in says nothing about how the user felt. As a zero it would drag the line
    // down for every busy day.
    func test_init_deliversAGapForADayWithNoCheckIn() {
        let keys = axis(days: 3)
        let sut = ReadinessSeries(days: [day(keys[0], readiness: 0.8), day(keys[2], readiness: 0.6)], metric: .readiness, dayKeys: keys)

        XCTAssertEqual(sut.values.count, 3)
        XCTAssertNil(sut.values[1])
        XCTAssertEqual(try XCTUnwrap(sut.values[2]), 0.6, accuracy: 0.0001)
    }

    func test_init_averagesTheCheckInsInTheLastSevenDays() throws {
        let keys = axis(days: 7)
        let days = [0.6, 0.7, 0.8].enumerated().map { day(keys[$0.offset * 2], readiness: $0.element) }

        let sut = ReadinessSeries(days: days, metric: .readiness, dayKeys: keys)

        XCTAssertEqual(try XCTUnwrap(sut.average.last ?? nil), 0.7, accuracy: 0.0001)
    }

    // One answer after a week away is not a week's trend.
    func test_init_deliversNoAverageWithFewerThanThreeCheckIns() {
        let keys = axis(days: 7)
        let sut = ReadinessSeries(days: [day(keys[5], readiness: 0.6), day(keys[6], readiness: 0.7)], metric: .readiness, dayKeys: keys)

        XCTAssertNil(sut.average.last ?? nil)
    }

    // On readiness's own scale, so a question that pulls readiness down sits below it.
    func test_init_putsAQuestionOnTheReadinessScale() throws {
        let keys = axis(days: 1)
        let sut = ReadinessSeries(days: [day(keys[0], readiness: 0.7, sleep: 2)], metric: .sleep, dayKeys: keys)

        XCTAssertEqual(try XCTUnwrap(sut.values[0]), 0.4, accuracy: 0.0001)
    }

    func test_mean_deliversNilWithNoCheckIns() {
        XCTAssertNil(ReadinessSeries.mean(of: .readiness, in: [], over: axis(days: 7)))
    }

    func test_formatted_deliversEachInItsOwnUnits() {
        XCTAssertEqual(ReadinessMetric.readiness.formatted(0.724), "72%")
        XCTAssertEqual(ReadinessMetric.sleep.formatted(0.72), "3.6 / 5")
    }

    // MARK: - Decoding

    // The id is the document's `date`; a day with only a rating has none of the scores.
    func test_decode_deliversARatingOnlyDay() throws {
        let json = #"{"date": "2026-11-10", "sleep": null, "readiness": null, "dayRPE": 7}"#

        let sut = try JSONDecoder().decode(ReadinessDay.self, from: Data(json.utf8))

        XCTAssertEqual(sut.id, "2026-11-10")
        XCTAssertNil(sut.readiness)
        XCTAssertNil(sut.mood)
        XCTAssertEqual(sut.dayRPE, 7)
    }

    // MARK: - Helpers

    private var today: Date {
        DateFormatter.yyyyMMdd.date(from: "2026-11-10")!
    }

    private func axis(days: Int) -> [String] {
        ReadinessSeries.dayKeys(length: days, endingOn: today)
    }

    private func day(_ key: String, readiness: Double, sleep: Int = 4) -> ReadinessDay {
        ReadinessDay(id: key, sleep: sleep, body: 4, focus: 4, mood: 4, readiness: readiness, dayRPE: nil)
    }
}
