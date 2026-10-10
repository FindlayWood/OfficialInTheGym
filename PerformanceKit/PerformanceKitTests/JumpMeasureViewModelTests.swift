//
//  JumpMeasureViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class JumpMeasureViewModelTests: XCTestCase {

    // h = t² × 1.22625 m. Half a second in the air is 0.25 × 1.22625 m,
    // 30.66 cm to two places. Getting the constant or the square wrong moves
    // every jump ever measured.
    func test_calculateJumpHeight_deliversCentimetresFromFlightTime() {
        let sut = makeSUT(takeOff: 1.0, landing: 1.5)

        XCTAssertEqual(sut.calculateJumpHeight(), 30.66, accuracy: 0.0001)
    }

    // Times exact in binary, so both subtractions give exactly 0.5 s and the
    // two-place rounding cannot split them.
    func test_calculateJumpHeight_dependsOnlyOnTimeInTheAir() {
        let early = makeSUT(takeOff: 0.25, landing: 0.75)
        let late = makeSUT(takeOff: 5.25, landing: 5.75)

        XCTAssertEqual(early.calculateJumpHeight(), late.calculateJumpHeight(), accuracy: 0.0001)
    }

    func test_areTimesValid_deliversTrueWhenTakeOffComesFirst() {
        XCTAssertTrue(makeSUT(takeOff: 1.0, landing: 1.5).areTimesValid())
    }

    func test_areTimesValid_deliversFalseWhenLandingIsNotAfterTakeOff() {
        XCTAssertFalse(makeSUT(takeOff: 1.5, landing: 1.0).areTimesValid())
        XCTAssertFalse(makeSUT(takeOff: 1.0, landing: 1.0).areTimesValid())
    }

    // Zero means untagged. A jump with only one end tagged must not reach the
    // calculation, which would treat the missing end as the start of the video.
    func test_areTimesValid_deliversFalseUntilBothAreTagged() {
        XCTAssertFalse(makeSUT(takeOff: 0, landing: 1.5).areTimesValid())
        XCTAssertFalse(makeSUT(takeOff: 1.0, landing: 0).areTimesValid())
    }

    func test_updateLandingTime_reportsValidityEachTime() {
        var sut = JumpMeasureViewModel()
        var reported: [Bool] = []
        sut.timeValidationCallback = { reported.append($0) }

        sut.updateLandingTime(with: 1.5)
        sut.updateTakeOffTime(with: 1.0)

        XCTAssertEqual(reported, [false, true])
    }

    // MARK: - Helpers

    private func makeSUT(takeOff: Double, landing: Double) -> JumpMeasureViewModel {
        var sut = JumpMeasureViewModel()
        sut.takeOffTime = takeOff
        sut.landingTime = landing
        return sut
    }
}
