//
//  JumpTestSessionViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class JumpTestSessionViewModelTests: XCTestCase {

    func test_add_stopsAtTheTestsAttempts() {
        let sut = makeSUT()

        (0..<4).forEach { _ in sut.add(attempt(40)) }

        XCTAssertEqual(sut.attempts.count, 3)
        XCTAssertFalse(sut.canRecordMore)
    }

    func test_canSave_deliversTrueFromTheFirstAttempt() {
        let sut = makeSUT()
        XCTAssertFalse(sut.canSave)

        sut.add(attempt(40))

        XCTAssertTrue(sut.canSave)
    }

    func test_bestIndex_deliversTheFirstOfEqualHighest() {
        let sut = makeSUT()
        [40, 44, 44].forEach { sut.add(attempt($0)) }

        XCTAssertEqual(sut.bestIndex, 1)
    }

    func test_removeAttempt_freesTheSlotToRecordAgain() {
        let sut = makeSUT()
        [40, 44, 42].forEach { sut.add(attempt($0)) }

        sut.removeAttempt(at: 1)

        XCTAssertEqual(sut.attempts.map(\.height), [40, 42])
        XCTAssertTrue(sut.canRecordMore)
    }

    func test_save_writesTheSessionAndHandsItOn() async {
        let spy = JumpTestServicesSpy()
        let sut = makeSUT(spy: spy)
        var finished: [JumpTestSession] = []
        sut.onFinished = { finished.append($0) }
        [40, 44].forEach { sut.add(attempt($0)) }

        await sut.save()

        let expected = JumpTestSession(id: "session-id", kind: .verticalJump, date: .fixed, attempts: [attempt(40), attempt(44)])
        XCTAssertEqual(spy.receivedMessages, [.write(expected)])
        XCTAssertEqual(finished, [expected])
    }

    // The id is fixed when the sitting starts. A retry with a fresh id would
    // save the same jumps as a second session.
    func test_save_retriesUnderTheSameId() async {
        let spy = JumpTestServicesSpy(writeError: NSError(domain: "test", code: 0))
        let sut = makeSUT(spy: spy)
        sut.add(attempt(40))

        await sut.save()
        XCTAssertNotNil(sut.saveError)
        XCTAssertFalse(sut.isSaving)
        spy.writeError = nil
        await sut.save()

        let ids = spy.receivedMessages.compactMap { message -> String? in
            if case .write(let session) = message { return session.id }
            return nil
        }
        XCTAssertEqual(ids, ["session-id", "session-id"])
        XCTAssertNil(sut.saveError)
    }

    // Power is worked out with the weight the athlete was when they jumped.
    // Saving without it would leave the session's power to whatever they weigh
    // later.
    func test_save_storesTheBodyMassForACMJ() async {
        let spy = JumpTestServicesSpy()
        let sut = makeSUT(kind: .cmj, spy: spy, bodyMass: 72)
        await sut.loadBodyMass()
        sut.add(attempt(40))

        await sut.save()

        guard case .write(let session) = spy.receivedMessages.first else { return XCTFail("Expected a write") }
        XCTAssertEqual(session.bodyMass ?? 0, 72, accuracy: 0.0001)
    }

    func test_save_storesNoBodyMassForATestWithoutPower() async {
        let spy = JumpTestServicesSpy()
        let sut = makeSUT(kind: .verticalJump, spy: spy, bodyMass: 72)
        await sut.loadBodyMass()
        sut.add(attempt(40))

        await sut.save()

        guard case .write(let session) = spy.receivedMessages.first else { return XCTFail("Expected a write") }
        XCTAssertNil(session.bodyMass)
    }

    func test_bestPower_followsTheBestAttempt() async throws {
        let sut = makeSUT(kind: .cmj, bodyMass: 80)
        await sut.loadBodyMass()
        [40, 45].forEach { sut.add(attempt($0)) }

        let power = try XCTUnwrap(sut.bestPower)

        XCTAssertEqual(power.watts, 60.7 * 45 + 45.3 * 80 - 2055, accuracy: 0.0001)
    }

    // No logged weight is no power, not a failed test. The jumps must still save.
    func test_save_succeedsWithoutABodyMass() async {
        let spy = JumpTestServicesSpy()
        let sut = makeSUT(kind: .cmj, spy: spy, bodyMass: nil)
        await sut.loadBodyMass()
        sut.add(attempt(40))

        await sut.save()

        XCTAssertNil(sut.saveError)
        XCTAssertNil(sut.bestPower)
        XCTAssertEqual(spy.receivedMessages.count, 1)
    }

    func test_save_doesNothingWithNoAttempts() async {
        let spy = JumpTestServicesSpy()
        let sut = makeSUT(spy: spy)

        await sut.save()

        XCTAssertEqual(spy.receivedMessages, [])
    }

    // MARK: - Helpers

    private func makeSUT(kind: JumpTestKind = .verticalJump, spy: JumpTestServicesSpy = JumpTestServicesSpy(), bodyMass: Double? = nil) -> JumpTestSessionViewModel {
        JumpTestSessionViewModel(
            kind: kind,
            writer: spy,
            bodyMassLoader: BodyMassLoaderStub(bodyMass: bodyMass),
            now: { .fixed },
            makeId: { "session-id" }
        )
    }

    private func attempt(_ height: Double) -> JumpAttempt {
        JumpAttempt(height: height, flightTime: nil, contactTime: nil)
    }
}
