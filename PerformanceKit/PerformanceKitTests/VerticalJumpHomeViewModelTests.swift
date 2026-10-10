//
//  VerticalJumpHomeViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class VerticalJumpHomeViewModelTests: XCTestCase {

    func test_load_asksForVerticalJumpSessions() async {
        let spy = JumpTestServicesSpy()
        let sut = VerticalJumpHomeViewModel(loader: spy, canRecord: true)

        await sut.load()

        XCTAssertEqual(spy.receivedMessages, [.loadSessions(.verticalJump)])
        XCTAssertFalse(sut.isLoading)
    }

    func test_best_andLatest_deliverFromTheSessions() async {
        let old = JumpTestSession.make(id: "old", daysAgo: 20, heights: [46])
        let new = JumpTestSession.make(id: "new", daysAgo: 1, heights: [41])
        let sut = VerticalJumpHomeViewModel(loader: JumpTestServicesSpy(sessionsResult: .success([new, old])), canRecord: true)

        await sut.load()

        XCTAssertEqual(sut.best?.id, "old")
        XCTAssertEqual(sut.latest?.id, "new")
    }

    // A session just saved must count at once. Without it the best on screen
    // ignores the jump the athlete has just made until they leave and return.
    func test_sessionSaved_countsTowardTheBestAtOnce() async {
        let sut = VerticalJumpHomeViewModel(loader: JumpTestServicesSpy(sessionsResult: .success([.make(id: "old", heights: [40])])), canRecord: true)
        await sut.load()

        sut.sessionSaved(.make(id: "new", heights: [45]))

        XCTAssertEqual(sut.best?.id, "new")
        XCTAssertEqual(sut.sessions.count, 2)
    }
}
