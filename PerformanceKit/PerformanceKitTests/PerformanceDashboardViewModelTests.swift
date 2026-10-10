//
//  PerformanceDashboardViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class PerformanceDashboardViewModelTests: XCTestCase {

    func test_tools_deliversEveryTestInOrder() {
        let sut = makeSUT()

        XCTAssertEqual(sut.tools, [.cmj, .verticalJump, .dropJump, .singleLegCMJ, .repeatedJumps, .balance])
    }

    func test_load_readsCMJAndVerticalJump() async {
        let loader = KindedSessionsLoader(cmj: .success([cmj(daysAgo: 1, 40)]), verticalJump: .success([vertical(48)]))
        let sut = makeSUT(loader: loader)

        await sut.load()

        XCTAssertEqual(sut.bestCMJ?.best?.height ?? 0, 40, accuracy: 0.0001)
        XCTAssertEqual(sut.bestVerticalJump?.best?.height ?? 0, 48, accuracy: 0.0001)
        XCTAssertTrue(sut.hasLoaded)
    }

    // The two reads fail on their own. A Vertical Jump read that fails must not
    // hide this week's check, which is the reason the screen exists.
    func test_load_keepsTheCheckWhenVerticalJumpFails() async {
        let loader = KindedSessionsLoader(cmj: .success([cmj(daysAgo: 1, 40)]), verticalJump: .failure(NSError(domain: "test", code: 0)))
        let sut = makeSUT(loader: loader)

        await sut.load()

        XCTAssertNotNil(sut.check.latest)
        XCTAssertNil(sut.bestVerticalJump)
    }

    func test_isCheckDue_deliversTrueAWeekAfterTheLastCMJ() async {
        let loader = KindedSessionsLoader(cmj: .success([cmj(daysAgo: 7, 40)]), verticalJump: .success([]))
        let sut = makeSUT(loader: loader)

        await sut.load()

        XCTAssertTrue(sut.isCheckDue)
    }

    func test_isCheckDue_deliversFalseWithinTheWeek() async {
        let loader = KindedSessionsLoader(cmj: .success([cmj(daysAgo: 3, 40)]), verticalJump: .success([]))
        let sut = makeSUT(loader: loader)

        await sut.load()

        XCTAssertFalse(sut.isCheckDue)
    }

    // A check saved from the dashboard has to show at once. Without it the
    // card still says the check is due, straight after the athlete did it.
    func test_sessionSaved_updatesTheCheckAtOnce() async {
        let sut = makeSUT(loader: KindedSessionsLoader(cmj: .success([cmj(daysAgo: 10, 40)]), verticalJump: .success([])))
        await sut.load()
        XCTAssertTrue(sut.isCheckDue)

        sut.sessionSaved(cmj(daysAgo: 0, 41))

        XCTAssertFalse(sut.isCheckDue)
    }

    func test_bestPower_deliversTheHighestPowerPerKilogram() async throws {
        let light = JumpTestSession(id: "a", kind: .cmj, date: .fixed, attempts: [attempt(40)], bodyMass: 70)
        let heavy = JumpTestSession(id: "b", kind: .cmj, date: .fixed, attempts: [attempt(40)], bodyMass: 90)
        let sut = makeSUT(loader: KindedSessionsLoader(cmj: .success([light, heavy]), verticalJump: .success([])))

        await sut.load()

        let power = try XCTUnwrap(sut.bestPower)
        XCTAssertEqual(power.wattsPerKilogram, JumpPower(heightCentimetres: 40, bodyMassKilograms: 70)!.wattsPerKilogram, accuracy: 0.0001)
    }

    // MARK: - Helpers

    private func makeSUT(loader: JumpTestSessionsLoader = KindedSessionsLoader()) -> PerformanceDashboardViewModel {
        PerformanceDashboardViewModel(loader: loader, canRecord: true, now: { .fixed }, calendar: .utc)
    }

    private func cmj(daysAgo: Double, _ height: Double) -> JumpTestSession {
        JumpTestSession(id: UUID().uuidString, kind: .cmj, date: Date.fixed.addingTimeInterval(-daysAgo * 86_400), attempts: [attempt(height)])
    }

    private func vertical(_ height: Double) -> JumpTestSession {
        JumpTestSession(id: UUID().uuidString, kind: .verticalJump, date: .fixed, attempts: [attempt(height)])
    }

    private func attempt(_ height: Double) -> JumpAttempt {
        JumpAttempt(height: height, flightTime: nil, contactTime: nil)
    }
}

/// Answers each kind with its own result, so a test can fail one read and not
/// the other.
private final class KindedSessionsLoader: JumpTestSessionsLoader, @unchecked Sendable {
    let cmj: Result<[JumpTestSession], Error>
    let verticalJump: Result<[JumpTestSession], Error>

    init(cmj: Result<[JumpTestSession], Error> = .success([]), verticalJump: Result<[JumpTestSession], Error> = .success([])) {
        self.cmj = cmj
        self.verticalJump = verticalJump
    }

    func loadSessions(_ kind: JumpTestKind) async throws -> [JumpTestSession] {
        switch kind {
        case .cmj: try cmj.get()
        case .verticalJump: try verticalJump.get()
        case .dropJump, .singleLegCMJ, .repeatedJumps: []
        }
    }
}
