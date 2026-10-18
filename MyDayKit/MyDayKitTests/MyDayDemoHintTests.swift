//
//  MyDayDemoHintTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/10/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayDemoHintTests: XCTestCase {

    func test_notice_deliversStartHintBeforeSessionStarts() {
        let sut = MyDayDemoHint.notice(for: manager(), initialSetCount: 9)

        XCTAssertEqual(sut.text, "Tap Start Workout when you're ready")
        XCTAssertEqual(sut.detail, MyDayDemoHint.detail)
    }

    // Quick-complete is the gesture nothing on screen announces, so it is the
    // first hint once the session runs.
    func test_notice_deliversQuickCompleteHintWithNothingLogged() {
        let sut = manager(started: true)

        XCTAssertEqual(MyDayDemoHint.notice(for: sut, initialSetCount: 9).text, "Tap a set's circle to log it as written")
    }

    // Derived from the session, not stored: un-logging walks the hint back.
    func test_notice_walksBackWhenSetIsUnlogged() {
        let sut = manager(started: true)
        log(sets: 1, on: sut)
        sut.uncompleteSet(exerciseId: firstExerciseId(sut), setId: firstSetId(sut))

        XCTAssertEqual(MyDayDemoHint.notice(for: sut, initialSetCount: 9).text, "Tap a set's circle to log it as written")
    }

    func test_notice_deliversAddSetHintAfterTwoLogsUntilASetIsAdded() {
        let sut = manager(started: true)
        log(sets: 2, on: sut)

        XCTAssertEqual(MyDayDemoHint.notice(for: sut, initialSetCount: 9).text, "Want one more? Tap Add Set under any exercise")

        sut.addSet(toExercise: firstExerciseId(sut))

        XCTAssertEqual(MyDayDemoHint.notice(for: sut, initialSetCount: 9).text, "Tap Finish Workout whenever you're done")
    }

    // Past a few logs the Add Set hint would nag someone who just wants to finish.
    func test_notice_deliversFinishHintAfterFourLogsWithoutAddingASet() {
        let sut = manager(started: true)
        log(sets: 4, on: sut)

        XCTAssertEqual(MyDayDemoHint.notice(for: sut, initialSetCount: 9).text, "Tap Finish Workout whenever you're done")
    }

    // MARK: - Helpers

    private func manager(started: Bool = false) -> WorkoutSessionManager {
        let manager = WorkoutSessionManager(entry: MyDayDemoWorkout.entry(at: fixedDate), userId: MyDayDemoWorkout.userId)
        if started { manager.startSession() }
        return manager
    }

    private func log(sets count: Int, on manager: WorkoutSessionManager) {
        let pairs = manager.entry.template.exercises.flatMap { exercise in
            exercise.sets.map { (exercise.exerciseId, $0.id) }
        }
        for (exerciseId, setId) in pairs.prefix(count) {
            manager.completeSet(exerciseId: exerciseId, setId: setId, reps: 10, weight: nil, weightUnit: nil, time: nil, distance: nil, distanceUnit: nil)
        }
    }

    private func firstExerciseId(_ manager: WorkoutSessionManager) -> String {
        manager.entry.template.exercises[0].exerciseId
    }

    private func firstSetId(_ manager: WorkoutSessionManager) -> String {
        manager.entry.template.exercises[0].sets[0].id
    }

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
}
