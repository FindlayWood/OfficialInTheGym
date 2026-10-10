//
//  BalanceSessionTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class BalanceSessionTests: XCTestCase {

    func test_best_deliversTheLowestSwayOnTheLeg() {
        let sut = session([stand(14, .left), stand(11, .left), stand(9, .right)])

        XCTAssertEqual(sut.best(on: .left)?.sway, 11)
    }

    // A stand cut short sways less simply by being short. Counting it would
    // reward putting a foot down.
    func test_best_ignoresStandsStoppedEarly() {
        let sut = session([stand(14, .left), BalanceAttempt(sway: 4, duration: 8, side: .left)])

        XCTAssertEqual(sut.best(on: .left)?.sway, 14)
    }

    // Lower sway is the better leg, so the leg that sways more is the weaker.
    // Reading it the jump way round would name the steadier leg as weak.
    func test_symmetry_namesTheLegThatSwaysMoreAsWeaker() throws {
        let sut = session([stand(10, .left), stand(12.5, .right)])

        let symmetry = try XCTUnwrap(sut.symmetry)
        XCTAssertEqual(symmetry.weaker, .right)
        XCTAssertEqual(symmetry.asymmetry, 0.2, accuracy: 0.0001)
    }

    func test_symmetry_deliversNilWithoutAFullStandOnEachLeg() {
        let sut = session([stand(10, .left), BalanceAttempt(sway: 8, duration: 12, side: .right)])

        XCTAssertNil(sut.symmetry)
    }

    // MARK: - Helpers

    private func stand(_ sway: Double, _ side: JumpSide) -> BalanceAttempt {
        BalanceAttempt(sway: sway, duration: 30, side: side)
    }

    private func session(_ attempts: [BalanceAttempt]) -> BalanceSession {
        BalanceSession(id: "s", date: .fixed, condition: .eyesOpen, attempts: attempts)
    }
}
