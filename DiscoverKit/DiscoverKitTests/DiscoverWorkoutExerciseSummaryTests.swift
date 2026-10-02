//
//  DiscoverWorkoutExerciseSummaryTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 02/10/2026.
//

import XCTest
@testable import DiscoverKit

final class DiscoverWorkoutExerciseSummaryTests: XCTestCase {

    func test_summary_deliversSetsRepsAndLoadWhenEverySetMatches() {
        let sut = exercise((0..<4).map { _ in set(reps: 8, weight: 80, unit: "kg") })

        XCTAssertEqual(sut.summary, "4 × 8 · 80 kg")
    }

    func test_summary_deliversARepRangeWhenRepsVary() {
        let sut = exercise([8, 10, 12].map { set(reps: $0, weight: 70, unit: "% of 1RM") })

        XCTAssertEqual(sut.summary, "3 × 8–12 · 70 % of 1RM")
    }

    // A varying load is left out rather than averaged: the average is a weight
    // nobody prescribed.
    func test_summary_leavesOutALoadThatVaries() {
        let sut = exercise([60, 70, 80].map { set(reps: 5, weight: $0, unit: "kg") })

        XCTAssertEqual(sut.summary, "3 × 5")
    }

    func test_summary_deliversAUnitThatLabelsTheSetAlone() {
        let sut = exercise((0..<3).map { _ in set(reps: 10, weight: nil, unit: "BW") })

        XCTAssertEqual(sut.summary, "3 × 10 · BW")
    }

    func test_summary_deliversTimedSetsWithoutReps() {
        let sut = exercise((0..<3).map { _ in DiscoverWorkoutSet(reps: nil, weight: nil, weightUnit: nil, time: 90, distance: nil, distanceUnit: nil) })

        XCTAssertEqual(sut.summary, "3 sets · 1m 30s")
    }

    func test_summary_deliversDistanceWithItsUnit() {
        let sut = exercise([DiscoverWorkoutSet(reps: nil, weight: nil, weightUnit: nil, time: nil, distance: 5, distanceUnit: "km")])

        XCTAssertEqual(sut.summary, "1 set · 5 km")
    }

    func test_summary_deliversNoSetsWhenEmpty() {
        XCTAssertEqual(exercise([]).summary, "No sets")
    }

    // MARK: - Helpers

    private func exercise(_ sets: [DiscoverWorkoutSet]) -> DiscoverWorkoutExercise {
        DiscoverWorkoutExercise(id: "e1", name: "Squat", sets: sets, notes: nil)
    }

    private func set(reps: Int?, weight: Double?, unit: String?) -> DiscoverWorkoutSet {
        DiscoverWorkoutSet(reps: reps, weight: weight, weightUnit: unit, time: nil, distance: nil, distanceUnit: nil)
    }
}
