//
//  JumpTestSessionTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class JumpTestSessionTests: XCTestCase {

    func test_best_deliversTheHighestAttempt() {
        let sut = JumpTestSession.make(heights: [40.2, 42.8, 41.0])

        XCTAssertEqual(sut.best?.height ?? 0, 42.8, accuracy: 0.0001)
    }

    func test_best_deliversNilWithNoAttempts() {
        XCTAssertNil(JumpTestSession.make(heights: []).best)
    }

    func test_bestOfSessions_deliversTheSessionWithTheHighestBest() {
        let low = JumpTestSession.make(id: "low", daysAgo: 1, heights: [38])
        let high = JumpTestSession.make(id: "high", daysAgo: 5, heights: [36, 44])

        XCTAssertEqual(JumpTestSession.best(of: [low, high])?.id, "high")
    }

    func test_power_deliversForACMJWithABodyMass() throws {
        let sut = JumpTestSession(id: "a", kind: .cmj, date: .fixed, attempts: [JumpAttempt(height: 40, flightTime: nil, contactTime: nil)], bodyMass: 75)

        let power = try XCTUnwrap(sut.power)
        XCTAssertEqual(power.watts, 3770.5, accuracy: 0.0001)
    }

    // The estimate was fitted to jumps without arm swing. Showing it for a
    // vertical jump would credit the legs with height the arms produced.
    func test_power_deliversNilForAVerticalJump() {
        let sut = JumpTestSession(id: "a", kind: .verticalJump, date: .fixed, attempts: [JumpAttempt(height: 40, flightTime: nil, contactTime: nil)], bodyMass: 75)

        XCTAssertNil(sut.power)
    }

    func test_power_deliversNilWithoutABodyMass() {
        let sut = JumpTestSession(id: "a", kind: .cmj, date: .fixed, attempts: [JumpAttempt(height: 40, flightTime: nil, contactTime: nil)])

        XCTAssertNil(sut.power)
    }

    // Equalling the best is not beating it. Moving the best to the later
    // session would change the date it was first reached.
    func test_bestOfSessions_keepsTheEarlierSessionOnATie() {
        let earlier = JumpTestSession.make(id: "earlier", daysAgo: 10, heights: [44])
        let later = JumpTestSession.make(id: "later", daysAgo: 1, heights: [44])

        XCTAssertEqual(JumpTestSession.best(of: [later, earlier])?.id, "earlier")
    }
}
