//
//  ExerciseLibraryTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 25/10/2026.
//

import XCTest
@testable import MyDayKit

final class ExerciseLibraryTests: XCTestCase {

    func test_init_deliversCatalogueAndCustomExercisesTogether() {
        let sut = ExerciseLibrary(catalogue: [catalogue("squat")], local: [custom("mine")], remote: [])

        XCTAssertEqual(Set(sut.exercises.map(\.id)), ["squat", "mine"])
    }

    // Approval writes `Exercises/{id}` under the custom exercise's own id. If
    // the user's copy still won, the picker would list the exercise twice, or
    // keep calling an approved exercise "Yours".
    func test_init_deliversCatalogueCopyWhenCustomIdHasBeenApproved() {
        let sut = ExerciseLibrary(
            catalogue: [catalogue("landmine", name: "Landmine Press")],
            local: [custom("landmine", name: "landmine press")],
            remote: []
        )

        XCTAssertEqual(sut.exercises.map(\.name), ["Landmine Press"])
        XCTAssertFalse(sut.isCustom(sut.exercises[0]))
    }

    func test_init_marksOnlyCustomExercisesAsCustom() {
        let sut = ExerciseLibrary(catalogue: [catalogue("squat")], local: [custom("mine")], remote: [])

        XCTAssertFalse(sut.isCustom(catalogue("squat")))
        XCTAssertTrue(sut.isCustom(catalogue("mine")))
    }

    // Local holds what has not synced; remote holds what was made on another
    // device. Dropping either side loses an exercise the user can see on the
    // other.
    func test_init_deliversCustomExercisesFromBothStores() {
        let sut = ExerciseLibrary(catalogue: [], local: [custom("here")], remote: [custom("elsewhere")])

        XCTAssertEqual(Set(sut.exercises.map(\.id)), ["here", "elsewhere"])
    }

    // An edit saved locally and not yet synced is newer than the remote copy.
    // Preferring remote by default would undo the edit until the sync landed.
    func test_init_deliversNewerCopyWhenBothStoresHoldTheSameExercise() {
        let sut = ExerciseLibrary(
            catalogue: [],
            local: [custom("mine", category: .core, updatedAt: fixedDate.addingTimeInterval(60))],
            remote: [custom("mine", category: .upperBody, updatedAt: fixedDate)]
        )

        XCTAssertEqual(sut.exercises.map(\.category), [.core])
    }

    // Only the remote copy carries the server's `status`; on a tie the local
    // copy would drop it.
    func test_init_deliversRemoteCopyOnATie() {
        let sut = ExerciseLibrary(
            catalogue: [],
            local: [custom("mine", updatedAt: fixedDate)],
            remote: [custom("mine", updatedAt: fixedDate, status: .pending)]
        )

        XCTAssertEqual(sut.customExercises["mine"]?.status, .pending)
    }

    // Delete is an archive: logs keep the id, but the picker must not offer it.
    func test_init_leavesOutArchivedExercises() {
        let sut = ExerciseLibrary(
            catalogue: [],
            local: [custom("gone", archivedAt: fixedDate)],
            remote: []
        )

        XCTAssertTrue(sut.exercises.isEmpty)
    }

    // An archive made on this device and not yet synced must win over the
    // older remote copy, or the exercise reappears.
    func test_init_leavesOutExerciseArchivedLocallyButNotYetRemotely() {
        let sut = ExerciseLibrary(
            catalogue: [],
            local: [custom("gone", updatedAt: fixedDate.addingTimeInterval(60), archivedAt: fixedDate)],
            remote: [custom("gone", updatedAt: fixedDate)]
        )

        XCTAssertTrue(sut.exercises.isEmpty)
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_790_000_000)

    private func catalogue(_ id: String, name: String = "Catalogue") -> Exercise {
        Exercise(id: id, name: name, category: .lowerBody)
    }

    private func custom(
        _ id: String,
        name: String = "Custom",
        category: ExerciseCategory = .upperBody,
        updatedAt: Date? = nil,
        archivedAt: Date? = nil,
        status: CustomExerciseStatus? = nil
    ) -> CustomExercise {
        CustomExercise(
            id: id,
            name: name,
            category: category,
            muscleGroups: ["chest"],
            movementPatterns: ["push_horizontal"],
            isCompound: true,
            isUnilateral: false,
            createdBy: "user",
            createdAt: fixedDate,
            updatedAt: updatedAt ?? fixedDate,
            archivedAt: archivedAt,
            status: status
        )
    }
}
