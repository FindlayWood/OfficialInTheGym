//
//  WorkoutSetOrderTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import MyDayKit

final class WorkoutSetOrderTests: XCTestCase {

    func test_steps_deliversAnExercisesSetsInOrderThenTheNextExercise() {
        let sut = WorkoutSetOrder.steps(for: [exercise("a", sets: 2), exercise("b", sets: 1)])

        XCTAssertEqual(sut.map(\.setId), ["a1", "a2", "b1"])
    }

    // The point of a superset: 1a straight into 1b, then back to 1a. Running each exercise's
    // sets to the end would make it two straight sets with nothing joining them.
    func test_steps_deliversSupersetInRounds() {
        let sut = WorkoutSetOrder.steps(for: [
            exercise("a", sets: 3, superset: "S"),
            exercise("b", sets: 3, superset: "S"),
            exercise("c", sets: 1)
        ])

        XCTAssertEqual(sut.map(\.setId), ["a1", "b1", "a2", "b2", "a3", "b3", "c1"])
    }

    // Set counts may differ inside a superset. The shorter exercise drops out of the last
    // rounds rather than leaving a hole or ending the superset early.
    func test_steps_dropsTheShorterExerciseFromLaterRounds() {
        let sut = WorkoutSetOrder.steps(for: [
            exercise("a", sets: 3, superset: "S"),
            exercise("b", sets: 1, superset: "S")
        ])

        XCTAssertEqual(sut.map(\.setId), ["a1", "b1", "a2", "a3"])
    }

    func test_next_deliversThePartnerExerciseInsideASuperset() {
        let exercises = [exercise("a", sets: 2, superset: "S"), exercise("b", sets: 2, superset: "S")]

        let sut = WorkoutSetOrder.next(after: step("a", "a1"), in: exercises, isLogged: { $0.setId == "a1" })

        XCTAssertEqual(sut, step("b", "b1"))
    }

    func test_next_deliversTheFirstExerciseAgainAfterTheLastOfARound() {
        let exercises = [exercise("a", sets: 2, superset: "S"), exercise("b", sets: 2, superset: "S")]
        let logged: Set<String> = ["a1", "b1"]

        let sut = WorkoutSetOrder.next(after: step("b", "b1"), in: exercises, isLogged: { logged.contains($0.setId) })

        XCTAssertEqual(sut, step("a", "a2"))
    }

    // A set logged ahead of time must not be pointed at again.
    func test_next_skipsSetsAlreadyLogged() {
        let exercises = [exercise("a", sets: 3)]
        let logged: Set<String> = ["a1", "a2"]

        let sut = WorkoutSetOrder.next(after: step("a", "a1"), in: exercises, isLogged: { logged.contains($0.setId) })

        XCTAssertEqual(sut, step("a", "a3"))
    }

    // Logging the last set with an earlier one still open sends the user back to it, not to
    // nothing.
    func test_next_wrapsToASkippedSetPastTheEnd() {
        let exercises = [exercise("a", sets: 2), exercise("b", sets: 1)]
        let logged: Set<String> = ["a2", "b1"]

        let sut = WorkoutSetOrder.next(after: step("b", "b1"), in: exercises, isLogged: { logged.contains($0.setId) })

        XCTAssertEqual(sut, step("a", "a1"))
    }

    func test_next_deliversNilOnceEverythingIsLogged() {
        let exercises = [exercise("a", sets: 2)]

        let sut = WorkoutSetOrder.next(after: step("a", "a2"), in: exercises, isLogged: { _ in true })

        XCTAssertNil(sut)
    }

    // MARK: - Helpers

    private func step(_ exerciseId: String, _ setId: String) -> WorkoutSetOrder.Step {
        WorkoutSetOrder.Step(exerciseId: exerciseId, setId: setId)
    }

    private func exercise(_ id: String, sets: Int, superset: String? = nil) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: id,
            exerciseId: id,
            exerciseName: id,
            exerciseCategory: .upperBody,
            orderIndex: 0,
            sets: (1...sets).map { WorkoutSetModel(id: "\(id)\($0)", orderIndex: $0 - 1, reps: 10) },
            supersetId: superset
        )
    }
}
