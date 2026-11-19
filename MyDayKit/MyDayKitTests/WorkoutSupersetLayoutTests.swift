//
//  WorkoutSupersetLayoutTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import MyDayKit

final class WorkoutSupersetLayoutTests: XCTestCase {

    // The shape the feature exists for: a superset counts once in the numbering, and its
    // exercises take letters.
    func test_init_deliversLettersInsideSupersetsAndNumbersBetween() {
        let sut = WorkoutSupersetLayout(supersetIds: ["A", "A", "A", nil, "B", "B"])

        XCTAssertEqual(sut.entries.map(\.label), ["1a", "1b", "1c", "2", "3a", "3b"])
        XCTAssertTrue(sut.hasSupersets)
    }

    // Every template written before supersets has no ids. It must read as the plain numbered
    // list it always was, and the screens must draw no labels for it.
    func test_init_deliversPlainNumbersWithoutSupersetIds() {
        let sut = WorkoutSupersetLayout(supersetIds: [nil, nil, nil])

        XCTAssertEqual(sut.entries.map(\.label), ["1", "2", "3"])
        XCTAssertEqual(sut.entries.map(\.position), [.single, .single, .single])
        XCTAssertFalse(sut.hasSupersets)
    }

    // An id on one exercise alone is not a superset — "1a" with no "1b" would promise a partner
    // that is not there.
    func test_init_deliversSingleForAnIdOnOneExercise() {
        let sut = WorkoutSupersetLayout(supersetIds: ["A", nil])

        XCTAssertEqual(sut.entries.map(\.label), ["1", "2"])
        XCTAssertFalse(sut.hasSupersets)
    }

    // A superset is consecutive. The same id either side of another exercise would otherwise
    // label two exercises "1a" and "1b" with a "2" drawn between them.
    func test_init_deliversSeparateNumbersForSameIdSplitByAnotherExercise() {
        let sut = WorkoutSupersetLayout(supersetIds: ["A", nil, "A"])

        XCTAssertEqual(sut.entries.map(\.label), ["1", "2", "3"])
    }

    func test_init_deliversTwoSupersetsBackToBackAsSeparateNumbers() {
        let sut = WorkoutSupersetLayout(supersetIds: ["A", "A", "B", "B"])

        XCTAssertEqual(sut.entries.map(\.label), ["1a", "1b", "2a", "2b"])
    }

    func test_init_deliversPositionsThroughASuperset() {
        let sut = WorkoutSupersetLayout(supersetIds: ["A", "A", "A"])

        XCTAssertEqual(sut.entries.map(\.position), [.first, .middle, .last])
    }

    func test_init_deliversDoubleLettersPastZ() {
        let sut = WorkoutSupersetLayout(supersetIds: Array(repeating: "A", count: 28))

        XCTAssertEqual(sut.entries[25].label, "1z")
        XCTAssertEqual(sut.entries[26].label, "1aa")
        XCTAssertEqual(sut.entries[27].label, "1ab")
    }

    func test_init_deliversNothingForNoExercises() {
        XCTAssertEqual(WorkoutSupersetLayout(supersetIds: []).entries, [])
    }

    // 1a goes straight into 1b; rest after 1a would break the superset into two exercises with
    // a pause between, which is what it exists to avoid.
    func test_restsAfter_deliversRestOnlyOnSingleAndLast() {
        XCTAssertTrue(WorkoutSupersetLayout.Position.single.restsAfter)
        XCTAssertFalse(WorkoutSupersetLayout.Position.first.restsAfter)
        XCTAssertFalse(WorkoutSupersetLayout.Position.middle.restsAfter)
        XCTAssertTrue(WorkoutSupersetLayout.Position.last.restsAfter)
    }

    func test_init_readsSupersetIdsOffExercises() {
        let sut = WorkoutSupersetLayout(exercises: [
            exercise("e1", supersetId: "A"),
            exercise("e2", supersetId: "A"),
            exercise("e3", supersetId: nil)
        ])

        XCTAssertEqual(sut.entries.map(\.label), ["1a", "1b", "2"])
    }

    // MARK: - Helpers

    private func exercise(_ id: String, supersetId: String?) -> WorkoutExerciseModel {
        WorkoutExerciseModel(
            id: id,
            exerciseId: id,
            exerciseName: id,
            exerciseCategory: .upperBody,
            orderIndex: 0,
            sets: [],
            supersetId: supersetId
        )
    }
}
