//
//  BalanceSwayTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class BalanceSwayTests: XCTestCase {

    // Sideways 0.01 g every sample, gravity straight down the phone's y axis:
    // RMS 0.01 g is 10 mg.
    func test_milliG_deliversTheRMSOfSidewaysAcceleration() {
        let samples = (0..<50).map { _ in sample(acceleration: [0.01, 0, 0]) }

        XCTAssertEqual(BalanceSway.milliG(from: samples), 10, accuracy: 0.0001)
    }

    // Bouncing up and down along gravity is not sway. Counting it would mark a
    // steady athlete who breathes hard as unsteady.
    func test_milliG_ignoresAccelerationAlongGravity() {
        let samples = (0..<50).map { _ in sample(acceleration: [0, 0.05, 0]) }

        XCTAssertEqual(BalanceSway.milliG(from: samples), 0, accuracy: 0.0001)
    }

    // Horizontal is taken against gravity, so how the phone is tilted on the
    // chest does not change the reading.
    func test_milliG_isTheSameWhateverWayThePhoneIsHeld() {
        let upright = [sample(gravity: [0, -1, 0], acceleration: [0.02, 0, 0])]
        let tilted = [sample(gravity: [0, 0, -1], acceleration: [0.02, 0, 0])]

        XCTAssertEqual(BalanceSway.milliG(from: upright), BalanceSway.milliG(from: tilted), accuracy: 0.0001)
    }

    func test_milliG_deliversZeroWithoutSamples() {
        XCTAssertEqual(BalanceSway.milliG(from: []), 0)
    }

    // MARK: - Helpers

    private func sample(gravity: SIMD3<Double> = [0, -1, 0], acceleration: SIMD3<Double>) -> MotionSample {
        MotionSample(gravity: gravity, acceleration: acceleration)
    }
}
