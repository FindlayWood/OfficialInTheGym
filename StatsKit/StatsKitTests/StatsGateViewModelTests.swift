//
//  StatsGateViewModelTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 12/10/2026.
//

import XCTest
@testable import StatsKit

@MainActor
final class StatsGateViewModelTests: XCTestCase {

    func test_init_deliversLockedWithoutPro() {
        let (sut, _) = makeSUT(hasUnlockedPro: false)

        XCTAssertFalse(sut.isUnlocked)
    }

    func test_init_deliversUnlockedWithPro() {
        let (sut, _) = makeSUT(hasUnlockedPro: true)

        XCTAssertTrue(sut.isUnlocked)
    }

    // The tab is built at launch. A gate that only read pro then would keep someone who has just
    // subscribed from the paywall looking at the locked screen until they relaunched.
    func test_refresh_unlocksOnceProArrives() {
        let (sut, access) = makeSUT(hasUnlockedPro: false)

        access.hasUnlockedPro = true
        sut.refresh()

        XCTAssertTrue(sut.isUnlocked)
    }

    func test_refresh_locksAgainWhenProLapses() {
        let (sut, access) = makeSUT(hasUnlockedPro: true)

        access.hasUnlockedPro = false
        sut.refresh()

        XCTAssertFalse(sut.isUnlocked)
    }

    func test_showPaywall_forwards() {
        let (sut, _) = makeSUT(hasUnlockedPro: false)
        var shown = 0
        sut.onShowPaywall = { shown += 1 }

        sut.showPaywall()

        XCTAssertEqual(shown, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        hasUnlockedPro: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (viewModel: StatsGateViewModel, access: StatsProAccessStub) {
        let access = StatsProAccessStub(hasUnlockedPro: hasUnlockedPro)
        let viewModel = StatsGateViewModel(proAccess: access)
        trackForMemoryLeaks(access, file: file, line: line)
        trackForMemoryLeaks(viewModel, file: file, line: line)
        return (viewModel, access)
    }
}
