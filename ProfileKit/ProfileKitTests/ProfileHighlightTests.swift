//
//  ProfileHighlightTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import XCTest
@testable import ProfileKit

final class ProfileHighlightTests: XCTestCase {

    func test_valueText_deliversWeightInKilograms() {
        XCTAssertEqual(highlight(weight: 140).valueText, "140 kg")
        XCTAssertEqual(highlight(weight: 102.5).valueText, "102.5 kg")
    }

    func test_valueText_deliversTimeInMinutesAndSeconds() {
        XCTAssertEqual(highlight(time: 45, timed: true).valueText, "45s")
        XCTAssertEqual(highlight(time: 120, timed: true).valueText, "2m")
        XCTAssertEqual(highlight(time: 150, timed: true).valueText, "2m 30s")
    }

    // MARK: - Helpers

    private func highlight(weight: Double = 0, time: Int = 0, timed: Bool = false) -> ProfileHighlight {
        ProfileHighlight(exerciseId: "e", exerciseName: "E", maxWeightKilograms: weight, maxTimeSeconds: time, isTimeBased: timed)
    }
}
