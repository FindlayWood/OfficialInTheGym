//
//  JumpPowerTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class JumpPowerTests: XCTestCase {

    // Sayers: 60.7 × 40 + 45.3 × 75 − 2055 = 2428 + 3397.5 − 2055 = 3770.5 W,
    // 50.27 W/kg. A wrong coefficient shifts every power the app has shown.
    func test_init_deliversTheSayersPeakPower() throws {
        let sut = try XCTUnwrap(JumpPower(heightCentimetres: 40, bodyMassKilograms: 75))

        XCTAssertEqual(sut.watts, 3770.5, accuracy: 0.0001)
        XCTAssertEqual(sut.wattsPerKilogram, 3770.5 / 75, accuracy: 0.0001)
    }

    func test_init_deliversNilWithoutAHeightOrAMass() {
        XCTAssertNil(JumpPower(heightCentimetres: 0, bodyMassKilograms: 75))
        XCTAssertNil(JumpPower(heightCentimetres: 40, bodyMassKilograms: 0))
    }

    // The equation goes negative for a tiny jump by a light athlete, which is
    // no power at all, not a negative one.
    func test_init_deliversNilRatherThanANegativePower() {
        XCTAssertNil(JumpPower(heightCentimetres: 5, bodyMassKilograms: 30))
    }
}
