//
//  LimbSymmetryTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class LimbSymmetryTests: XCTestCase {

    // The gap is a share of the stronger leg: 24 against 30 is 6 / 30 = 20%.
    // Dividing by the weaker leg would read 25% and flag more athletes.
    func test_asymmetry_deliversTheGapAsAShareOfTheStrongerLeg() throws {
        let sut = try XCTUnwrap(LimbSymmetry(left: 24, right: 30))

        XCTAssertEqual(sut.asymmetry, 0.20, accuracy: 0.0001)
        XCTAssertEqual(sut.weaker, .left)
        XCTAssertEqual(sut.summary, "Left leg 20% weaker")
    }

    func test_isNotable_fromTenPercent() throws {
        XCTAssertTrue(try XCTUnwrap(LimbSymmetry(left: 27, right: 30)).isNotable)
        XCTAssertFalse(try XCTUnwrap(LimbSymmetry(left: 27.1, right: 30)).isNotable)
    }

    func test_summary_deliversEvenForEqualLegs() throws {
        let sut = try XCTUnwrap(LimbSymmetry(left: 30, right: 30))

        XCTAssertNil(sut.weaker)
        XCTAssertEqual(sut.summary, "Even")
    }

    func test_weaker_deliversTheHigherFigureWhenLowerIsBetter() throws {
        let sut = try XCTUnwrap(LimbSymmetry(left: 10, right: 12, higherIsBetter: false))

        XCTAssertEqual(sut.weaker, .right)
    }

    func test_init_deliversNilWithoutBothLegs() {
        XCTAssertNil(LimbSymmetry(left: 0, right: 30))
    }
}
