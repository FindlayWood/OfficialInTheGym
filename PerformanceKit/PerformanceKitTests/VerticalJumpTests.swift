//
//  VerticalJumpTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class VerticalJumpTests: XCTestCase {

    func test_best_deliversTheNewJumpWhenThereIsNoBestYet() {
        let new = VerticalJump(time: .fixed, height: 30)

        let sut = VerticalJump.best(current: nil, new: new)

        XCTAssertEqual(sut, new)
    }

    func test_best_deliversTheNewJumpWhenItIsHigher() {
        let current = VerticalJump(time: .fixed.addingTimeInterval(-86_400), height: 40)
        let new = VerticalJump(time: .fixed, height: 41.5)

        let sut = VerticalJump.best(current: current, new: new)

        XCTAssertEqual(sut, new)
    }

    func test_best_keepsTheCurrentBestWhenTheNewJumpIsLower() {
        let current = VerticalJump(time: .fixed.addingTimeInterval(-86_400), height: 40)

        let sut = VerticalJump.best(current: current, new: VerticalJump(time: .fixed, height: 35))

        XCTAssertEqual(sut, current)
    }

    // Equalling the best is not beating it. Replacing it would move the date
    // the best was first reached to today.
    func test_best_keepsTheCurrentBestsDateWhenTheNewJumpOnlyEqualsIt() {
        let current = VerticalJump(time: .fixed.addingTimeInterval(-86_400), height: 40)

        let sut = VerticalJump.best(current: current, new: VerticalJump(time: .fixed, height: 40))

        XCTAssertEqual(sut.time, current.time)
    }
}
