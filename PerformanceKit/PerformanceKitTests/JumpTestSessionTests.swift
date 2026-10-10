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

    // Equalling the best is not beating it. Moving the best to the later
    // session would change the date it was first reached.
    func test_bestOfSessions_keepsTheEarlierSessionOnATie() {
        let earlier = JumpTestSession.make(id: "earlier", daysAgo: 10, heights: [44])
        let later = JumpTestSession.make(id: "later", daysAgo: 1, heights: [44])

        XCTAssertEqual(JumpTestSession.best(of: [later, earlier])?.id, "earlier")
    }
}
