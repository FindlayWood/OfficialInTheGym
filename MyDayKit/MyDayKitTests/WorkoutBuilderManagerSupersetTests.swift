//
//  WorkoutBuilderManagerSupersetTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import MyDayKit

final class WorkoutBuilderManagerSupersetTests: XCTestCase {

    func test_toggleLink_joinsExerciseToTheNext() {
        let (sut, exercises) = makeSUT(count: 3)

        sut.toggleLink(after: exercises[0])

        XCTAssertEqual(sut.supersetLayout.entries.map(\.label), ["1a", "1b", "2"])
    }

    // Linking onto an existing superset is how a tri-set is built: there is no separate
    // "add to superset" action.
    func test_toggleLink_extendsAnExistingSuperset() {
        let (sut, exercises) = makeSUT(count: 3)

        sut.toggleLink(after: exercises[0])
        sut.toggleLink(after: exercises[1])

        XCTAssertEqual(sut.supersetLayout.entries.map(\.label), ["1a", "1b", "1c"])
    }

    func test_toggleLink_splitsASupersetInTheMiddle() {
        let (sut, exercises) = makeSUT(count: 4)
        exercises.dropLast().forEach(sut.toggleLink(after:))

        sut.toggleLink(after: exercises[1])

        XCTAssertEqual(sut.supersetLayout.entries.map(\.label), ["1a", "1b", "2a", "2b"])
    }

    // The last exercise has nothing after it. A link stored on it would join whatever is
    // added next without the user asking.
    func test_toggleLink_doesNothingOnTheLastExercise() {
        let (sut, exercises) = makeSUT(count: 2)

        sut.toggleLink(after: exercises[1])

        XCTAssertFalse(sut.isLinkedToNext(exercises[1]))
    }

    // Deleting a superset's last exercise leaves its new last one linked to nothing; without
    // dropping that link, the next exercise added would silently join the superset.
    func test_removeExercises_dropsALinkLeftPointingPastTheEnd() {
        let (sut, exercises) = makeSUT(count: 2)
        sut.toggleLink(after: exercises[0])

        sut.removeExercises(atOffsets: [1])
        sut.addExercise(builder("late"))

        XCTAssertFalse(sut.isLinkedToNext(exercises[0]))
        XCTAssertEqual(sut.supersetLayout.entries.map(\.label), ["1", "2"])
    }

    func test_removeExercises_keepsTheRestOfASupersetTogether() {
        let (sut, exercises) = makeSUT(count: 3)
        exercises.dropLast().forEach(sut.toggleLink(after:))

        sut.removeExercises(atOffsets: [1])

        XCTAssertEqual(sut.supersetLayout.entries.map(\.label), ["1a", "1b"])
    }

    func test_supersetIds_deliversOneIdPerGroupAndNilForSingles() {
        let sut = WorkoutBuilderManager.supersetIds(
            linkedToNext: [true, true, false, false, true, false],
            makeId: { "g\($0)" }
        )

        XCTAssertEqual(sut, ["g0", "g0", "g0", nil, "g4", "g4"])
    }

    // What is built is what is saved: the template must carry one shared id per superset and
    // none on an exercise on its own, or every later screen reads a different shape.
    func test_uploadWorkout_buildsTemplateWithSharedSupersetIds() async {
        let (sut, exercises) = makeSUT(count: 3)
        sut.title = "Push"
        sut.toggleLink(after: exercises[0])
        var uploaded: WorkoutTemplateModel?
        sut.onUploadSuccess = { uploaded = $0 }

        await sut.uploadWorkout()

        let ids = uploaded?.exercises.map(\.supersetId) ?? []
        XCTAssertEqual(ids.count, 3)
        XCTAssertNotNil(ids[0])
        XCTAssertEqual(ids[0], ids[1])
        XCTAssertNil(ids[2])
    }

    // The manager outlives the builder screen. Links left on it would be meaningless (they key
    // on exercises that are gone) but must not survive into the next workout.
    func test_uploadWorkout_clearsLinksOnSuccess() async {
        let (sut, exercises) = makeSUT(count: 2)
        sut.title = "Push"
        sut.toggleLink(after: exercises[0])

        await sut.uploadWorkout()

        XCTAssertTrue(sut.supersetLinks.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(count: Int, file: StaticString = #filePath, line: UInt = #line) -> (WorkoutBuilderManager, [WorkoutExerciseBuilderManager]) {
        let sut = WorkoutBuilderManager(uploader: WorkoutTemplateUploaderSpy(), userId: "user")
        let exercises = (0..<count).map { builder("exercise-\($0)") }
        exercises.forEach(sut.addExercise)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, exercises)
    }

    private func builder(_ id: String) -> WorkoutExerciseBuilderManager {
        let manager = WorkoutExerciseBuilderManager(exercise: Exercise(id: id, name: id, category: .upperBody))
        manager.addSets(1)
        return manager
    }
}
