//
//  InjuryChartBandsTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import XCTest
@testable import StatsKit

final class InjuryChartBandsTests: XCTestCase {

    func test_bands_deliversTheIndicesAnInjuryCovers() {
        let injury = StatsInjury.fixture(startedDaysAgo: 4, resolvedDaysAgo: 1, from: today)

        XCTAssertEqual(InjuryChartBands.bands(for: [injury], over: axis(days: 10), today: today), [5...7])
    }

    // An injury that started before the chart's first day still shades from the left edge.
    func test_bands_clipsAnInjuryToTheAxis() {
        let injury = StatsInjury.fixture(startedDaysAgo: 30, from: today)

        XCTAssertEqual(InjuryChartBands.bands(for: [injury], over: axis(days: 10), today: today), [0...9])
    }

    func test_bands_dropsAnInjuryOutsideTheAxis() {
        let injury = StatsInjury.fixture(startedDaysAgo: 40, resolvedDaysAgo: 30, from: today)

        XCTAssertTrue(InjuryChartBands.bands(for: [injury], over: axis(days: 10), today: today).isEmpty)
    }

    func test_dayKeys_includeTodayForACurrentInjury() {
        let injury = StatsInjury.fixture(startedDaysAgo: 2, from: today)

        XCTAssertEqual(injury.dayKeys(today: today), ["2026-11-08", "2026-11-09", "2026-11-10"])
    }

    // MARK: - Helpers

    private var today: Date {
        DateFormatter.yyyyMMdd.date(from: "2026-11-10")!
    }

    /// The last `days` days, oldest first, as a chart's x-axis.
    private func axis(days: Int) -> [String] {
        (0..<days).reversed().map { StatsDay.key(daysAgo: $0, from: today) }
    }
}
