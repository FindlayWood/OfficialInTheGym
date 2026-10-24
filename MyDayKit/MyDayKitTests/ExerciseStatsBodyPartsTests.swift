//
//  ExerciseStatsBodyPartsTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 24/10/2026.
//

import XCTest
@testable import MyDayKit

final class ExerciseStatsBodyPartsTests: XCTestCase {

    // A set logged in a session knows the exercise only through the template.
    // A log without its body parts would make the server look the exercise up
    // again on every edit and delete, moving volume between groups whenever
    // the catalogue changed.
    func test_completeSet_deliversLogCarryingTemplateBodyParts() {
        let sut = WorkoutSessionManager(entry: entry(muscleGroups: ["quads", "glutes"], movementPatterns: ["squat"]), userId: "user")
        var logs: [ExerciseStatsSaveModel] = []
        sut.onSetLogged = { logs.append($0) }
        sut.startSession()

        sut.completeSet(exerciseId: "squat", setId: "s1", reps: 10, weight: 50, weightUnit: .kg, time: nil, distance: nil, distanceUnit: nil)

        XCTAssertEqual(logs.last?.muscleGroups, ["quads", "glutes"])
        XCTAssertEqual(logs.last?.movementPatterns, ["squat"])
    }

    // Absent means unknown, and the server falls back to the catalogue only
    // when the keys are missing. Coercing an older template's nil to [] would
    // record the set as counting toward nothing.
    func test_completeSet_deliversLogWithoutBodyPartsForOlderTemplate() {
        let sut = WorkoutSessionManager(entry: entry(muscleGroups: nil, movementPatterns: nil), userId: "user")
        var logs: [ExerciseStatsSaveModel] = []
        sut.onSetLogged = { logs.append($0) }
        sut.startSession()

        sut.completeSet(exerciseId: "squat", setId: "s1", reps: 10, weight: 50, weightUnit: .kg, time: nil, distance: nil, distanceUnit: nil)

        XCTAssertNotNil(logs.last)
        XCTAssertNil(logs.last?.muscleGroups)
        XCTAssertNil(logs.last?.movementPatterns)
    }

    // Add Set rebuilds the exercise from its fields. Leaving the body parts
    // out there would drop them from every set logged after the first tap.
    func test_addSet_keepsBodyParts() {
        let sut = WorkoutSessionManager(entry: entry(muscleGroups: ["quads"], movementPatterns: ["squat"]), userId: "user")

        sut.addSet(toExercise: "squat")

        XCTAssertEqual(sut.entry.template.exercises[0].muscleGroups, ["quads"])
        XCTAssertEqual(sut.entry.template.exercises[0].movementPatterns, ["squat"])
    }

    // The two getStats paths write to one collection; an exercise logged on
    // its own must carry body parts exactly as a session set does.
    func test_getStats_deliversExerciseBodyPartsForStandaloneCompletion() {
        let exercise = Exercise(id: "squat", name: "Squat", category: .lowerBody, muscleGroups: ["quads"], movementPatterns: ["squat"])
        let sut = ExerciseCompletions(
            id: "c1", exercise: exercise, reps: 5, weight: 100, weightUnit: .kg, dateCompleted: fixedDate,
            distance: nil, distanceUnits: nil, time: nil, tempo: nil, note: nil, eachSide: nil
        )

        let stats = sut.getStats()

        XCTAssertEqual(stats.muscleGroups, ["quads"])
        XCTAssertEqual(stats.movementPatterns, ["squat"])
    }

    // Every template already saved lacks both keys. A required field would
    // stop the whole library decoding.
    func test_decode_deliversNilBodyPartsForTemplateExerciseSavedBeforeThem() throws {
        let json = #"{"id":"e1","exerciseId":"squat","exerciseName":"Squat","exerciseCategory":"lower_body","orderIndex":0,"sets":[]}"#

        let sut = try JSONDecoder().decode(WorkoutExerciseModel.self, from: Data(json.utf8))

        XCTAssertNil(sut.muscleGroups)
        XCTAssertNil(sut.movementPatterns)
    }

    // Every day file embeds an Exercise written before body parts existed.
    func test_decode_deliversNilBodyPartsForExerciseSavedBeforeThem() throws {
        let json = #"{"id":"squat","name":"Squat","category":"lower_body"}"#

        let sut = try JSONDecoder().decode(Exercise.self, from: Data(json.utf8))

        XCTAssertNil(sut.muscleGroups)
        XCTAssertNil(sut.movementPatterns)
    }

    // MARK: - Helpers

    private func entry(muscleGroups: [String]?, movementPatterns: [String]?) -> DailyWorkoutEntry {
        DailyWorkoutEntry(
            template: WorkoutTemplateModel(
                id: "t1",
                title: "Legs",
                description: nil,
                exercises: [
                    WorkoutExerciseModel(
                        id: "e1",
                        exerciseId: "squat",
                        exerciseName: "Squat",
                        exerciseCategory: .lowerBody,
                        orderIndex: 0,
                        sets: [WorkoutSetModel(id: "s1", orderIndex: 0, reps: 10, weight: 50, weightUnit: .kg)],
                        muscleGroups: muscleGroups,
                        movementPatterns: movementPatterns
                    )
                ],
                createdBy: "user",
                isPublic: false,
                tags: nil,
                estimatedDuration: nil,
                difficulty: nil,
                createdAt: fixedDate,
                updatedAt: fixedDate
            ),
            assignedDate: fixedDate
        )
    }

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
}
