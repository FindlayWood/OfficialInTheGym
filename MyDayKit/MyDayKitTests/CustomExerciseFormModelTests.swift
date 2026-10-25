//
//  CustomExerciseFormModelTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 25/10/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class CustomExerciseFormModelTests: XCTestCase {

    func test_canSave_deliversTrueOnlyOnceEveryAnswerIsGiven() async {
        let sut = makeSUT()
        await sut.loadOptions()

        XCTAssertFalse(sut.canSave)
        sut.name = "Landmine Press"
        sut.category = .upperBody
        sut.toggleMuscleGroup("chest")
        sut.toggleMovementPattern("push_vertical")
        sut.isCompound = true
        XCTAssertFalse(sut.canSave, "Unilateral not answered yet")

        sut.isUnilateral = false

        XCTAssertTrue(sut.canSave)
    }

    // Answering `false` is an answer. A form that read `false` as unanswered
    // could never save a single-joint, both-sides exercise.
    func test_canSave_deliversTrueWhenBothFlagsAnsweredNo() async {
        let sut = makeSUT()
        await sut.loadOptions()

        fillIn(sut)
        sut.isCompound = false
        sut.isUnilateral = false

        XCTAssertTrue(sut.canSave)
    }

    func test_canSave_deliversFalseForANameOfOnlySpaces() async {
        let sut = makeSUT()
        await sut.loadOptions()
        fillIn(sut)

        sut.name = "   "

        XCTAssertFalse(sut.canSave)
    }

    // The name can never change after saving, so what is stored must be what
    // the user meant, not their stray spaces.
    func test_cleanedName_deliversTrimmedNameWithSpacesCollapsed() {
        let sut = makeSUT(name: "  Landmine   Press ")

        XCTAssertEqual(sut.cleanedName, "Landmine Press")
    }

    func test_name_isCappedAtMaxLength() {
        let sut = makeSUT(name: String(repeating: "a", count: 100))

        XCTAssertEqual(sut.name.count, CustomExerciseFormModel.maxNameLength)
    }

    func test_save_uploadsCompleteExerciseCreatedByTheInjectedUser() async {
        let saver = CustomExerciseUploaderSpy()
        let sut = makeSUT(saver: saver)
        await sut.loadOptions()
        fillIn(sut)

        let saved = await sut.save()

        XCTAssertEqual(saver.receivedMessages, saved.map { [.upload($0)] })
        XCTAssertEqual(saved?.name, "Landmine Press")
        XCTAssertEqual(saved?.createdBy, "user-1")
        XCTAssertEqual(saved?.isCompound, true)
        XCTAssertEqual(saved?.isUnilateral, false)
    }

    // Stored in the list's order, not tap order, so two people picking the same
    // muscles write the same array.
    func test_save_storesBodyPartsInTheListsOrder() async {
        let sut = makeSUT()
        await sut.loadOptions()
        fillIn(sut)
        sut.muscleGroups = []
        sut.toggleMuscleGroup("triceps")
        sut.toggleMuscleGroup("chest")

        let saved = await sut.save()

        XCTAssertEqual(saved?.muscleGroups, ["chest", "triceps"])
    }

    func test_save_deliversNilAndAnErrorWhenTheSaveFails() async {
        let saver = CustomExerciseUploaderSpy()
        saver.error = NSError(domain: "test", code: 0)
        let sut = makeSUT(saver: saver)
        await sut.loadOptions()
        fillIn(sut)

        let saved = await sut.save()

        XCTAssertNil(saved)
        XCTAssertNotNil(sut.saveError)
    }

    func test_save_uploadsNothingWhileIncomplete() async {
        let saver = CustomExerciseUploaderSpy()
        let sut = makeSUT(saver: saver)
        await sut.loadOptions()

        let saved = await sut.save()

        XCTAssertNil(saved)
        XCTAssertTrue(saver.receivedMessages.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        name: String = "",
        saver: CustomExerciseUploading = CustomExerciseUploaderSpy()
    ) -> CustomExerciseFormModel {
        CustomExerciseFormModel(
            name: name,
            dependencies: CustomExerciseDependencies(
                saver: saver,
                muscleGroups: PreviewExerciseMuscleGroupsLoader(),
                movementPatterns: PreviewExerciseMovementPatternsLoader(),
                userId: "user-1"
            )
        )
    }

    private func fillIn(_ sut: CustomExerciseFormModel) {
        sut.name = "Landmine Press"
        sut.category = .upperBody
        sut.toggleMuscleGroup("chest")
        sut.toggleMovementPattern("push_horizontal")
        sut.isCompound = true
        sut.isUnilateral = false
    }
}
