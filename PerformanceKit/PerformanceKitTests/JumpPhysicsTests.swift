//
//  JumpPhysicsTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class JumpPhysicsTests: XCTestCase {

    // h = t² × 1.22625 m. Half a second in the air is 0.25 × 1.22625 m,
    // 30.66 cm to two places. Getting the constant or the square wrong moves
    // every jump ever measured.
    func test_heightCentimetres_deliversCentimetresFromFlightTime() {
        XCTAssertEqual(JumpPhysics.heightCentimetres(flightTime: 0.5), 30.66, accuracy: 0.0001)
    }

    func test_heightCentimetres_deliversZeroForNoFlight() {
        XCTAssertEqual(JumpPhysics.heightCentimetres(flightTime: 0), 0, accuracy: 0.0001)
    }
}
