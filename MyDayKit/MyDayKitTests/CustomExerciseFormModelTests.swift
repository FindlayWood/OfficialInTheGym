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

    // Asking on every Save would turn a nudge into a gate.
    func test_saveOrAskFirst_asksOnceThenSaves() async {
        let saver = CustomExerciseUploaderSpy()
        let sut = makeSUT(saver: saver, existing: [similarPress])
        await sut.loadOptions()
        fillIn(sut)

        let first = await sut.saveOrAskFirst()
        XCTAssertNil(first)
        XCTAssertEqual(sut.similarOnSave?.map(\.name), ["Overhead Press"])
        XCTAssertTrue(saver.receivedMessages.isEmpty)

        sut.similarOnSave = nil
        let second = await sut.saveOrAskFirst()

        XCTAssertNotNil(second)
        XCTAssertEqual(saver.receivedMessages.count, 1)
    }

    func test_saveOrAskFirst_savesAtOnceWhenNothingIsSimilar() async {
        let saver = CustomExerciseUploaderSpy()
        let sut = makeSUT(saver: saver)
        await sut.loadOptions()
        fillIn(sut)

        let saved = await sut.saveOrAskFirst()

        XCTAssertNotNil(saved)
        XCTAssertNil(sut.similarOnSave)
    }

    // One or two letters match almost anything and would fill the screen
    // with suggestions before the user has said what they mean.
    func test_nameMatches_deliversNothingBelowThreeCharacters() {
        let sut = makeSUT(name: "Pr", existing: [similarPress], finder: EverythingFinder())

        XCTAssertTrue(sut.nameMatches.isEmpty)
    }

    func test_nameMatches_deliversWhatTheFinderFinds() {
        let sut = makeSUT(name: "Press", existing: [similarPress], finder: EverythingFinder())

        XCTAssertEqual(sut.nameMatches.map(\.name), ["Overhead Press"])
    }

    // MARK: - Helpers

    private let similarPress = Exercise(
        id: "ohp", name: "Overhead Press", category: .upperBody,
        muscleGroups: ["chest", "shoulders"], movementPatterns: ["push_horizontal"]
    )

    private struct EverythingFinder: SimilarExerciseFinder {
        func exercises(named name: String, in exercises: [Exercise], limit: Int) -> [Exercise] {
            Array(exercises.prefix(limit))
        }
    }

    private func makeSUT(
        name: String = "",
        saver: CustomExerciseUploading = CustomExerciseUploaderSpy(),
        existing: [Exercise] = [],
        finder: SimilarExerciseFinder = EmptySimilarExerciseFinder()
    ) -> CustomExerciseFormModel {
        CustomExerciseFormModel(
            name: name,
            existingExercises: existing,
            dependencies: CustomExerciseDependencies(
                saver: saver,
                muscleGroups: PreviewExerciseMuscleGroupsLoader(),
                movementPatterns: PreviewExerciseMovementPatternsLoader(),
                similarExercises: finder,
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
