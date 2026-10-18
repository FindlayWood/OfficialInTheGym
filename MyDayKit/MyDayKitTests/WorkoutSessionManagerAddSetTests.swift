//
//  WorkoutSessionManagerAddSetTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/10/2026.
//

import XCTest
@testable import MyDayKit

final class WorkoutSessionManagerAddSetTests: XCTestCase {

    // "One more" should be one tap: a new set copying the previous set's
    // prescription quick-completes at the same numbers. An empty set would
    // fall through to the overlay with nothing to log.
    func test_addSet_appendsSetCopyingLastPrescription() {
        let sut = WorkoutSessionManager(entry: entry(), userId: "user")

        sut.addSet(toExercise: "squat")

        let sets = sut.entry.template.exercises[0].sets
        XCTAssertEqual(sets.count, 3)
        XCTAssertEqual(sets[2].orderIndex, 2)
        XCTAssertEqual(sets[2].reps, 8)
        XCTAssertEqual(sets[2].weight ?? 0, 60, accuracy: 0.001)
        XCTAssertEqual(sets[2].weightUnit, .kg)
        XCTAssertNotEqual(sets[2].id, sets[1].id)
    }

    // The screen draws pills from the template and logs against records by
    // set id. A set added mid-session with no record would draw but never log.
    func test_addSet_addsEmptyRecordWhenSessionStarted() {
        let sut = WorkoutSessionManager(entry: entry(), userId: "user")
        sut.startSession()

        sut.addSet(toExercise: "squat")
        let newSetId = sut.entry.template.exercises[0].sets[2].id
        sut.completeSet(exerciseId: "squat", setId: newSetId, reps: 8, weight: 60, weightUnit: .kg, time: nil, distance: nil, distanceUnit: nil)

        XCTAssertEqual(sut.setRecords(for: "squat").count, 3)
        XCTAssertEqual(sut.setRecord(exerciseId: "squat", setId: newSetId)?.isCompleted, true)
        XCTAssertEqual(sut.totalSetsTargeted, 3)
    }

    // A finished session is a record of work done; adding to it afterwards
    // would change the targeted count of a workout already completed.
    func test_addSet_doesNothingOnceCompleted() {
        let sut = WorkoutSessionManager(entry: entry(), userId: "user")
        sut.startSession()
        sut.finishSession(rpe: 5, notes: nil)

        sut.addSet(toExercise: "squat")

        XCTAssertEqual(sut.entry.template.exercises[0].sets.count, 2)
    }

    // The demo saves nothing because the manager's callbacks are unwired; a
    // real session wires them, and an added set has to reach the day file.
    func test_addSet_notifiesEntryUpdated() {
        let sut = WorkoutSessionManager(entry: entry(), userId: "user")
        var updates: [DailyWorkoutEntry] = []
        sut.onEntryUpdated = { updates.append($0) }

        sut.addSet(toExercise: "squat")

        XCTAssertEqual(updates.last?.template.exercises[0].sets.count, 3)
    }

    // MARK: - Helpers

    private func entry() -> DailyWorkoutEntry {
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
                        sets: [
                            WorkoutSetModel(id: "s1", orderIndex: 0, reps: 10, weight: 50, weightUnit: .kg),
                            WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 60, weightUnit: .kg)
                        ]
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
