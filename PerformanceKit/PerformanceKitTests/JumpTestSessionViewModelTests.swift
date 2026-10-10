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

    func test_save_doesNothingWithNoAttempts() async {
        let spy = JumpTestServicesSpy()
        let sut = makeSUT(spy: spy)

        await sut.save()

        XCTAssertEqual(spy.receivedMessages, [])
    }

    // MARK: - Helpers

    private func makeSUT(spy: JumpTestServicesSpy = JumpTestServicesSpy()) -> JumpTestSessionViewModel {
        JumpTestSessionViewModel(kind: .verticalJump, writer: spy, now: { .fixed }, makeId: { "session-id" })
    }

    private func attempt(_ height: Double) -> JumpAttempt {
        JumpAttempt(height: height, flightTime: nil, contactTime: nil)
    }
}
