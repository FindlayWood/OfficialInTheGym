//
//  DailyTotalDecodingTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 09/08/2026.
//

import XCTest
@testable import StatsKit

final class DailyTotalDecodingTests: XCTestCase {

    func test_decode_deliversNoWorkloadForDocumentWrittenBeforeTheFieldExisted() throws {
        // Every DailyTotals document written before the workload aggregation
        // shipped lacks the key. Decoding it non-optionally would throw for all
        // of them, and the tab would render as though the user had no history.
        let sut = try decode(makeJSON())

        XCTAssertNil(sut.totalWorkload)
        XCTAssertEqual(TrainingLoadMetric.session.load(from: sut), 0)
        XCTAssertEqual(TrainingLoadMetric.volume.load(from: sut), 5000)
    }

    func test_decode_deliversWorkloadWhenPresent() throws {
        let sut = try decode(makeJSON(extra: ["totalWorkload": 420]))

        XCTAssertEqual(sut.totalWorkload, 420)
        XCTAssertEqual(TrainingLoadMetric.session.load(from: sut), 420)
    }

    func test_decode_deliversEmptyBreakdownsWhenAbsent() throws {
        let sut = try decode(makeJSON())

        XCTAssertEqual(sut.muscleGroupVolumes, [:])
        XCTAssertEqual(sut.movementTypeVolumes, [:])
        XCTAssertEqual(sut.exerciseSetCounts, [:])
    }

    // MARK: - Helpers

    private func decode(_ json: Data) throws -> DailyTotal {
        try JSONDecoder().decode(DailyTotal.self, from: json)
    }

    private func makeJSON(extra: [String: Any] = [:]) -> Data {
        var payload: [String: Any] = [
            "id": "2026-08-01",
            "date": 0,
            "userID": "any",
            "totalSets": 12,
            "totalReps": 120,
            "totalWeight": 500,
            "totalVolume": 5000,
            "totalTime": 0
        ]
        extra.forEach { payload[$0.key] = $0.value }
        return try! JSONSerialization.data(withJSONObject: payload)
    }
}
