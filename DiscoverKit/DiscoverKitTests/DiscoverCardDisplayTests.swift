//
//  DiscoverCardDisplayTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 28/09/2026.
//

import XCTest
@testable import DiscoverKit

final class DiscoverCardDisplayTests: XCTestCase {

    func test_categoryDisplayName_deliversTitleCasedWordsFromSnakeCase() {
        let sut = exercise(category: "upper_body")

        XCTAssertEqual(sut.categoryDisplayName, "Upper Body")
    }

    func test_categoryDisplayName_deliversNilWithoutCategory() {
        let sut = exercise(category: nil)

        XCTAssertNil(sut.categoryDisplayName)
    }

    func test_formattedDuration_deliversMinutesAndPaddedSeconds() {
        XCTAssertEqual(clip(duration: 12.4).formattedDuration, "0:12")
        XCTAssertEqual(clip(duration: 65).formattedDuration, "1:05")
    }

    func test_formattedDuration_roundsToTheNearestSecond() {
        let sut = clip(duration: 12.6)

        XCTAssertEqual(sut.formattedDuration, "0:13")
    }

    func test_formattedDuration_deliversNilWithoutDuration() {
        let sut = clip(duration: nil)

        XCTAssertNil(sut.formattedDuration)
    }

    // MARK: - Helpers

    private func exercise(category: String?) -> DiscoverExerciseCard {
        DiscoverExerciseCard(exerciseId: "squat", name: "Squat", category: category)
    }

    private func clip(duration: Double?) -> DiscoverClipCard {
        DiscoverClipCard(
            clipId: "clip",
            exerciseId: nil,
            exerciseName: nil,
            videoURL: nil,
            thumbnailURL: nil,
            durationSeconds: duration,
            createdBy: nil,
            uploadedAt: nil
        )
    }
}
