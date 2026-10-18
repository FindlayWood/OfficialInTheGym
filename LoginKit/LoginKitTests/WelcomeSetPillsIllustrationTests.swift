//
//  WelcomeSetPillsIllustrationTests.swift
//  LoginKitTests
//
//  Created by Findlay Wood on 18/10/2026.
//

import XCTest
@testable import LoginKit

final class WelcomeSetPillsIllustrationTests: XCTestCase {

    func test_loggedCount_deliversIntroFourBeforeAnyScene() {
        XCTAssertEqual(WelcomeSetPillsIllustration.loggedCount(scene: 0), 4)
    }

    // Each scene logs one more pill until all six are done, then resets — a
    // session that never filled up, or filled and stayed full, would stop
    // telling the story after a few seconds.
    func test_loggedCount_deliversOneMorePerSceneThenResets() {
        let sut = (1...8).map(WelcomeSetPillsIllustration.loggedCount(scene:))

        XCTAssertEqual(sut, [5, 6, 3, 4, 5, 6, 3, 4])
    }
}
