//
//  ProfileHighlightFirestoreTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit
import XCTest
@testable import InTheGym

final class ProfileHighlightFirestoreTests: XCTestCase {

    func test_init_readsAProfileHighlightsEntry() {
        let sut = ProfileHighlight(highlightData: [
            "exerciseId": "squat", "exerciseName": "Back Squat", "maxWeight": 140.5, "maxTime": 0, "isTimeBased": false
        ])

        XCTAssertEqual(sut, ProfileHighlight(
            exerciseId: "squat", exerciseName: "Back Squat", maxWeightKilograms: 140.5, maxTimeSeconds: 0, isTimeBased: false
        ))
    }

    // An ExerciseStats document has no isTimeBased flag. Reading it as loaded
    // would show a plank as "0 kg".
    func test_init_appliesStatsKitsTimedRuleWhenTheFlagIsMissing() {
        let sut = ProfileHighlight(
            highlightData: ["exerciseID": "plank", "exerciseName": "Plank", "maxWeight": 0, "maxTime": 90, "totalTime": 600],
            exerciseId: "plank"
        )

        XCTAssertEqual(sut?.isTimeBased, true)
        XCTAssertEqual(sut?.maxTimeSeconds, 90)
    }

    // Firestore hands back whole numbers as integers; a weight of 100 must not
    // read as missing because it is not a Double.
    func test_init_readsIntegerWeights() {
        let sut = ProfileHighlight(highlightData: ["exerciseId": "bench", "maxWeight": 100])

        XCTAssertEqual(sut?.maxWeightKilograms ?? 0, 100, accuracy: 0.001)
    }

    func test_init_usesTheDocumentIdWhenTheDataHasNone() {
        let sut = ProfileHighlight(highlightData: ["maxWeight": 60], exerciseId: "doc-id")

        XCTAssertEqual(sut?.exerciseId, "doc-id")
    }

    func test_init_deliversNilWithNoIdAtAll() {
        XCTAssertNil(ProfileHighlight(highlightData: ["maxWeight": 60]))
    }
}
