//
//  MyDayScrollTargetTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayScrollTargetTests: XCTestCase {

    func test_after_deliversANewExercise() {
        let sut = MyDayScrollTarget.after(snapshot(day()), snapshot(day(exercises: [exercise("e1", sets: ["s1"])])))

        XCTAssertEqual(sut, .exercise(id: "e1"))
    }

    // Saving a set appends to the same `MyDayExerciseModel` the old day held. Comparing the
    // days themselves would see the set on both sides and find nothing; the snapshot is what
    // keeps a before.
    func test_after_deliversASetAppendedToTheSameExerciseInstance() {
        let model = exercise("e1", sets: ["s1"])
        let before = snapshot(day(exercises: [model]))

        model.completions.append(completion("s2"))
        let sut = MyDayScrollTarget.after(before, snapshot(day(exercises: [model])))

        XCTAssertEqual(sut, .set(exerciseId: "e1", setId: "s2"))
    }

    // "Filled in" includes correcting a set: the edited one is what the user is looking for.
    func test_after_deliversAnEditedSet() {
        let model = exercise("e1", sets: ["s1", "s2"])
        let before = snapshot(day(exercises: [model]))

        model.completions[0] = completion("s1", reps: 12)
        let sut = MyDayScrollTarget.after(before, snapshot(day(exercises: [model])))

        XCTAssertEqual(sut, .set(exerciseId: "e1", setId: "s1"))
    }

    func test_after_deliversAddedWorkoutAndSport() {
        let workoutDay = day(workouts: [workout("w1")])
        XCTAssertEqual(MyDayScrollTarget.after(snapshot(day()), snapshot(workoutDay)), .workout(id: "w1"))

        let sportDay = day(sports: [.basketballGame(performedAt: fixedDate)])
        let sportId = sportDay.sports?.first?.id ?? ""
        XCTAssertEqual(MyDayScrollTarget.after(snapshot(day()), snapshot(sportDay)), .sport(id: sportId))
    }

    func test_after_deliversCheckInAndRatingWhenFilledOrChanged() {
        XCTAssertEqual(MyDayScrollTarget.after(snapshot(day()), snapshot(day(checkIn: .four))), .checkIn)
        XCTAssertEqual(MyDayScrollTarget.after(snapshot(day(checkIn: .four)), snapshot(day(checkIn: .two))), .checkIn)
        XCTAssertEqual(MyDayScrollTarget.after(snapshot(day()), snapshot(day(rating: 7))), .rating)
    }

    // Moving along the date strip replaces the whole day. Scrolling to "what changed" there
    // would jump to whatever the other day happens to hold.
    func test_after_deliversNilForADifferentDay() {
        let other = day(id: "other", exercises: [exercise("e1", sets: ["s1"])])

        XCTAssertNil(MyDayScrollTarget.after(snapshot(day()), snapshot(other)))
    }

    func test_after_deliversNilWithNoBeforeOrNoChange() {
        let model = day(exercises: [exercise("e1", sets: ["s1"])])

        XCTAssertNil(MyDayScrollTarget.after(nil, snapshot(model)))
        XCTAssertNil(MyDayScrollTarget.after(snapshot(model), snapshot(model)))
    }

    // Something removed is gone; there is nothing to show.
    func test_after_deliversNilForARemoval() {
        let before = snapshot(day(exercises: [exercise("e1", sets: ["s1"])], workouts: [workout("w1")]))

        XCTAssertNil(MyDayScrollTarget.after(before, snapshot(day())))
    }

    func test_rowId_deliversTheCardOfASetsExercise() {
        XCTAssertEqual(MyDayScrollTarget.set(exerciseId: "e1", setId: "s1").rowId, "exercise-e1")
        XCTAssertEqual(MyDayScrollTarget.set(exerciseId: "e1", setId: "s1").setId, "s1")
        XCTAssertNil(MyDayScrollTarget.exercise(id: "e1").setId)
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    private let squat = Exercise(id: "squat", name: "Squat", category: .lowerBody)

    private func snapshot(_ day: MyDayFullDayModel) -> MyDayDaySnapshot {
        MyDayDaySnapshot(day)
    }

    private func day(
        id: String = "day",
        exercises: [MyDayExerciseModel] = [],
        workouts: [DailyWorkoutEntry] = [],
        sports: [SportSessionEntry]? = nil,
        checkIn: WellnessScore? = nil,
        rating: Int? = nil
    ) -> MyDayFullDayModel {
        MyDayFullDayModel(
            id: id,
            date: fixedDate,
            exercises: exercises,
            workouts: workouts,
            rpeEntry: rating.map { RPEEntry(id: "rpe", date: fixedDate, score: $0) },
            wellnessEntry: checkIn.map {
                WellnessEntry(id: "wellness", date: fixedDate, sleepQuality: $0, physicalReadiness: $0, mentalEnergy: $0, overallMood: $0)
            },
            sports: sports
        )
    }

    private func exercise(_ id: String, sets: [String]) -> MyDayExerciseModel {
        MyDayExerciseModel(id: id, date: fixedDate, exercise: squat, completions: sets.map { completion($0) }, clips: [])
    }

    private func completion(_ id: String, reps: Int = 8) -> ExerciseCompletions {
        ExerciseCompletions(
            id: id, exercise: squat, reps: reps, weight: 60, weightUnit: .kg, dateCompleted: fixedDate,
            distance: nil, distanceUnits: nil, time: nil, tempo: nil, note: nil, eachSide: nil
        )
    }

    private func workout(_ id: String) -> DailyWorkoutEntry {
        DailyWorkoutEntry(
            id: id,
            template: WorkoutTemplateModel(
                id: "t", title: "Legs", description: nil, exercises: [], createdBy: "user", isPublic: false,
                tags: nil, estimatedDuration: nil, difficulty: nil, createdAt: fixedDate, updatedAt: fixedDate
            ),
            assignedDate: fixedDate
        )
    }
}
