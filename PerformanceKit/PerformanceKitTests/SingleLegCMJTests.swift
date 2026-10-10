//
//  SingleLegCMJTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class SingleLegCMJTests: XCTestCase {

    func test_add_recordsOnTheSelectedLeg() {
        let sut = makeSUT()

        sut.add(attempt(24))

        XCTAssertEqual(sut.attempts.map(\.side), [.left])
    }

    // A full leg hands over to the other, or the next Record would be refused
    // with nothing on screen saying the athlete has to switch.
    func test_add_movesToTheOtherLegOnceOneIsFull() {
        let sut = makeSUT()

        (0..<3).forEach { _ in sut.add(attempt(24)) }

        XCTAssertEqual(sut.selectedSide, .right)
        XCTAssertTrue(sut.canRecordMore)
    }

    // The result is the comparison, so it cannot be saved with one leg alone.
    func test_canSave_deliversTrueOnlyOnceBothLegsHaveAJump() {
        let sut = makeSUT()
        sut.add(attempt(24))
        XCTAssertFalse(sut.canSave)

        sut.selectedSide = .right
        sut.add(attempt(27))

        XCTAssertTrue(sut.canSave)
    }

    func test_symmetry_comparesEachLegsBest() throws {
        let sut = makeSUT()
        [22, 24].forEach { sut.add(attempt($0)) }
        sut.selectedSide = .right
        sut.add(attempt(30))

        let symmetry = try XCTUnwrap(sut.symmetry)
        XCTAssertEqual(symmetry.left, 24, accuracy: 0.0001)
        XCTAssertEqual(symmetry.right, 30, accuracy: 0.0001)
    }

    // A session ranks by its weaker leg, so a better session is one where the
    // weak leg improved, not one where the strong leg jumped higher still.
    func test_bestOfSessions_ranksByTheWeakerLeg() {
        let lopsided = session("lopsided", left: 20, right: 34)
        let even = session("even", left: 26, right: 27)

        XCTAssertEqual(JumpTestSession.best(of: [lopsided, even])?.id, "even")
    }

    // MARK: - Helpers

    private func makeSUT() -> JumpTestSessionViewModel {
        JumpTestSessionViewModel(kind: .singleLegCMJ, writer: JumpTestServicesSpy(), bodyMassLoader: BodyMassLoaderStub(), now: { .fixed }, makeId: { "s" })
    }

    private func attempt(_ height: Double) -> JumpAttempt {
        JumpAttempt(height: height, flightTime: nil, contactTime: nil)
    }

    private func session(_ id: String, left: Double, right: Double) -> JumpTestSession {
        JumpTestSession(id: id, kind: .singleLegCMJ, date: .fixed, attempts: [attempt(left).on(.left), attempt(right).on(.right)])
    }
}
