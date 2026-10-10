//
//  PerformanceGateViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class PerformanceGateViewModelTests: XCTestCase {

    func test_init_deliversLockedWithoutPro() {
        let sut = PerformanceGateViewModel(proAccess: PerformanceProAccessStub(hasUnlockedPro: false))

        XCTAssertFalse(sut.isUnlocked)
    }

    func test_init_deliversUnlockedWithPro() {
        let sut = PerformanceGateViewModel(proAccess: PerformanceProAccessStub(hasUnlockedPro: true))

        XCTAssertTrue(sut.isUnlocked)
    }

    // The tab is built at launch. A gate that only read pro then would keep
    // someone who has just subscribed locked out until they relaunched.
    func test_refresh_unlocksOnceProArrives() {
        let access = PerformanceProAccessStub(hasUnlockedPro: false)
        let sut = PerformanceGateViewModel(proAccess: access)

        access.hasUnlockedPro = true
        sut.refresh()

        XCTAssertTrue(sut.isUnlocked)
    }

    func test_refresh_locksAgainWhenProLapses() {
        let access = PerformanceProAccessStub(hasUnlockedPro: true)
        let sut = PerformanceGateViewModel(proAccess: access)

        access.hasUnlockedPro = false
        sut.refresh()

        XCTAssertFalse(sut.isUnlocked)
    }

    func test_showPaywall_forwards() {
        let sut = PerformanceGateViewModel(proAccess: PerformanceProAccessStub(hasUnlockedPro: false))
        var shown = 0
        sut.onShowPaywall = { shown += 1 }

        sut.showPaywall()

        XCTAssertEqual(shown, 1)
    }

    // The testing unlock exists only in emulator builds, where the composition
    // root sets it. Offering the button without it would be a dead button.
    func test_canUnlockForTesting_deliversFalseUnlessSet() {
        let sut = PerformanceGateViewModel(proAccess: PerformanceProAccessStub(hasUnlockedPro: false))

        XCTAssertFalse(sut.canUnlockForTesting)
    }

    func test_unlockForTesting_unlocksWhenTheOverrideGrantsPro() {
        let access = PerformanceProAccessStub(hasUnlockedPro: false)
        let sut = PerformanceGateViewModel(proAccess: access)
        sut.onUnlockForTesting = { access.hasUnlockedPro = true }

        sut.unlockForTesting()

        XCTAssertTrue(sut.canUnlockForTesting)
        XCTAssertTrue(sut.isUnlocked)
    }
}
