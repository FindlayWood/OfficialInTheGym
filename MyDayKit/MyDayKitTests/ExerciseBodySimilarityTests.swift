//
//  ExerciseBodySimilarityTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 25/10/2026.
//

import XCTest
@testable import MyDayKit

final class ExerciseBodySimilarityTests: XCTestCase {

    func test_matches_deliversExerciseSharingAPatternAndAMuscleGroup() {
        let sut = matches(groups: ["biceps"], patterns: ["isolation"])

        XCTAssertEqual(sut, ["Dumbbell Curl"])
    }

    // A shared pattern alone would flag every isolation exercise against every
    // other; a shared muscle alone, half the catalogue.
    func test_matches_deliversNothingForAPatternOrAMuscleAlone() {
        XCTAssertEqual(matches(groups: ["biceps"], patterns: ["hinge"]), [])
        XCTAssertEqual(matches(groups: ["hamstrings"], patterns: ["squat"]), [])
    }

    func test_matches_ranksByMuscleGroupsShared() {
        let sut = matches(groups: ["hamstrings", "glutes", "lower_back"], patterns: ["hinge"], limit: 2)

        XCTAssertEqual(sut, ["Deadlift", "Romanian Deadlift"])
    }

    // The name check already offers an exact match; the body check is for
    // the same movement under a *different* name.
    func test_matches_leavesOutAnExerciseOfTheSameName() {
        let sut = matches(groups: ["hamstrings"], patterns: ["hinge"], name: "romanian deadlift")

        XCTAssertFalse(sut.contains("Romanian Deadlift"))
    }

    // An untagged catalogue exercise cannot be compared, and guessing would
    // flag it against everything or nothing.
    func test_matches_leavesOutExercisesWithNoBodyFields() {
        let sut = ExerciseBodySimilarity.matches(
            muscleGroups: ["chest"],
            movementPatterns: ["push_horizontal"],
            excludingName: "",
            in: [Exercise(id: "old", name: "Old Press", category: .upperBody)],
            limit: 3
        )

        XCTAssertTrue(sut.isEmpty)
    }

    // MARK: - Helpers

    private func matches(
        groups: Set<String>,
        patterns: Set<String>,
        name: String = "My Hinge",
        limit: Int = 3
    ) -> [String] {
        ExerciseBodySimilarity.matches(
            muscleGroups: groups,
            movementPatterns: patterns,
            excludingName: name,
            in: catalogue,
            limit: limit
        ).map(\.name)
    }

    private let catalogue = [
        Exercise(id: "rdl", name: "Romanian Deadlift", category: .lowerBody,
                 muscleGroups: ["hamstrings", "glutes"], movementPatterns: ["hinge"]),
        Exercise(id: "dl", name: "Deadlift", category: .lowerBody,
                 muscleGroups: ["hamstrings", "glutes", "lower_back"], movementPatterns: ["hinge"]),
        Exercise(id: "curl", name: "Leg Curl", category: .lowerBody,
                 muscleGroups: ["hamstrings"], movementPatterns: ["isolation"]),
        Exercise(id: "bicep", name: "Dumbbell Curl", category: .upperBody,
                 muscleGroups: ["biceps"], movementPatterns: ["isolation"])
    ]
}
