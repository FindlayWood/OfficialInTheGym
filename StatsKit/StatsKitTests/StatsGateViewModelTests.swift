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
        let sut = StatsGateViewModel(proAccess: StatsProAccessStub(hasUnlockedPro: false))

        XCTAssertFalse(sut.isUnlocked)
    }

    func test_init_deliversUnlockedWithPro() {
        let sut = StatsGateViewModel(proAccess: StatsProAccessStub(hasUnlockedPro: true))

        XCTAssertTrue(sut.isUnlocked)
    }

    // The tab is built at launch. A gate that only read pro then would keep someone who has just
    // subscribed from the paywall looking at the locked screen until they relaunched.
    func test_refresh_unlocksOnceProArrives() {
        let access = StatsProAccessStub(hasUnlockedPro: false)
        let sut = StatsGateViewModel(proAccess: access)

        access.hasUnlockedPro = true
        sut.refresh()

        XCTAssertTrue(sut.isUnlocked)
    }

    func test_refresh_locksAgainWhenProLapses() {
        let access = StatsProAccessStub(hasUnlockedPro: true)
        let sut = StatsGateViewModel(proAccess: access)

        access.hasUnlockedPro = false
        sut.refresh()

        XCTAssertFalse(sut.isUnlocked)
    }

    func test_showPaywall_forwards() {
        let sut = StatsGateViewModel(proAccess: StatsProAccessStub(hasUnlockedPro: false))
        var shown = 0
        sut.onShowPaywall = { shown += 1 }

        sut.showPaywall()

        XCTAssertEqual(shown, 1)
    }
}
