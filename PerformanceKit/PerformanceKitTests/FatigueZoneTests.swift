//
//  FatigueZoneTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class FatigueZoneTests: XCTestCase {

    // The boundaries belong to the higher zone: exactly 95% is fresh and
    // exactly 90% is caution. Moving either shifts what every check says.
    func test_init_deliversTheZoneForEachBoundary() {
        XCTAssertEqual(FatigueZone(fraction: 1.02), .fresh)
        XCTAssertEqual(FatigueZone(fraction: 0.95), .fresh)
        XCTAssertEqual(FatigueZone(fraction: 0.9499), .caution)
        XCTAssertEqual(FatigueZone(fraction: 0.90), .caution)
        XCTAssertEqual(FatigueZone(fraction: 0.8999), .fatigued)
    }
}
