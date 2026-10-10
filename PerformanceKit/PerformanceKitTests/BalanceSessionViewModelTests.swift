//
//  BalanceSessionViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class BalanceSessionViewModelTests: XCTestCase {

    func test_add_movesToTheOtherLegOnceOneIsFull() {
        let sut = makeSUT()

        sut.add(stand(12))
        sut.add(stand(11))

        XCTAssertEqual(sut.selectedSide, .right)
        XCTAssertEqual(sut.attempts.map(\.side), [.left, .left])
    }

    func test_canSave_deliversTrueOnceEachLegHasAStand() {
        let sut = makeSUT()
        sut.add(stand(12))
        XCTAssertFalse(sut.canSave)

        sut.selectedSide = .right
        sut.add(stand(13))

        XCTAssertTrue(sut.canSave)
    }

    func test_save_writesTheConditionAndStands() async {
        let spy = BalanceServicesSpy()
        let sut = makeSUT(spy: spy)
        sut.condition = .eyesClosed
        sut.add(stand(12))
        sut.selectedSide = .right
        sut.add(stand(13))

        await sut.save()

        guard case .write(let session) = spy.receivedMessages.first else { return XCTFail("Expected a write") }
        XCTAssertEqual(session.id, "b")
        XCTAssertEqual(session.condition, .eyesClosed)
        XCTAssertEqual(session.attempts.count, 2)
    }

    // MARK: - Helpers

    private func makeSUT(spy: BalanceServicesSpy = BalanceServicesSpy()) -> BalanceSessionViewModel {
        BalanceSessionViewModel(writer: spy, now: { .fixed }, makeId: { "b" })
    }

    private func stand(_ sway: Double) -> BalanceAttempt {
        BalanceAttempt(sway: sway, duration: 30, side: .left)
    }
}
