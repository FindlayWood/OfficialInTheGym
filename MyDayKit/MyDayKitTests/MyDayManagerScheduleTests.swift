//
//  MyDayManagerScheduleTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class MyDayManagerScheduleTests: XCTestCase {

    // MARK: - Adding

    func test_addScheduledWorkout_savesTheEntryOnToday() async {
        let sut = await makeSUT()
        sut.selectedDay = makeDay(date: Date())

        sut.addScheduledWorkout(scheduledEntry())

        XCTAssertEqual(sut.selectedDay?.workouts.map(\.scheduleId), ["schedule"])
    }

    // The phone's day-file saver names its file by today's date, so saving any other day would
    // overwrite today's file.
    func test_addScheduledWorkout_doesNothingOnAnotherDay() async {
        let sut = await makeSUT()
        sut.selectedDay = makeDay(date: Date().addingTimeInterval(-86_400 * 2))

        sut.addScheduledWorkout(scheduledEntry())

        XCTAssertEqual(sut.selectedDay?.workouts.count, 0)
    }

    // MARK: - Removing

    // Without the skip, the saved entry going would bring the due card straight back.
    func test_removeWorkoutFromDay_skipsTheScheduleOfASavedEntry() async {
        let sut = await makeSUT()
        let entry = scheduledEntry()
        sut.selectedDay = makeDay(date: Date(), workouts: [entry])

        sut.removeWorkoutFromDay(entry)

        XCTAssertEqual(sut.selectedDay?.workouts.count, 0)
        XCTAssertEqual(sut.selectedDay?.skippedSchedules, ["schedule"])
    }

    // "Not Today" on a card that was never saved. There is no entry to remove, and the skip is the
    // only thing that takes the card away.
    func test_removeWorkoutFromDay_skipsTheScheduleOfADueCard() async {
        let sut = await makeSUT()
        sut.selectedDay = makeDay(date: Date())

        sut.removeWorkoutFromDay(scheduledEntry())

        XCTAssertEqual(sut.selectedDay?.skippedSchedules, ["schedule"])
    }

    func test_removeWorkoutFromDay_recordsNoSkipForAWorkoutAddedByHand() async {
        let sut = await makeSUT()
        let entry = DailyWorkoutEntry(template: .fixture(), assignedDate: Date())
        sut.selectedDay = makeDay(date: Date(), workouts: [entry])

        sut.removeWorkoutFromDay(entry)

        XCTAssertNil(sut.selectedDay?.skippedSchedules)
    }

    func test_removeWorkoutFromDay_keepsACompletedScheduledWorkout() async {
        let sut = await makeSUT()
        let entry = scheduledEntry(status: .completed)
        sut.selectedDay = makeDay(date: Date(), workouts: [entry])

        sut.removeWorkoutFromDay(entry)

        XCTAssertEqual(sut.selectedDay?.workouts.count, 1)
        XCTAssertNil(sut.selectedDay?.skippedSchedules)
    }

    // MARK: - Helpers

    private func scheduledEntry(status: DailyWorkoutStatus = .planned) -> DailyWorkoutEntry {
        DailyWorkoutEntry(id: "entry", template: .fixture(), assignedDate: Date(), status: status, scheduleId: "schedule")
    }

    private func makeDay(date: Date, workouts: [DailyWorkoutEntry] = []) -> MyDayFullDayModel {
        MyDayFullDayModel(id: "day", date: date, exercises: [], workouts: workouts)
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) async -> MyDayManager {
        let sut = MyDayManager(
            saver: PreviewSaver(),
            clipSaver: PreviewMyDaySaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: PreviewLoader(),
            deleter: PreviewMyDayDeleter(),
            wellnessSaver: PreviewMyDaySaver(),
            rpeSaver: PreviewMyDaySaver(),
            workoutSaver: PreviewMyDaySaver(),
            workoutStatsSaver: PreviewExerciseStatsSaver(),
            completedSessionSaver: PreviewCompletedWorkoutSessionSaver(),
            completedSessionDeleter: PreviewCompletedWorkoutSessionDeleter()
        )
        await waitForInitialLoad(of: sut)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    /// `MyDayManager.init` loads today in a `Task`. Waiting for it means that load cannot land after a
    /// test has set the day itself and overwrite it.
    private func waitForInitialLoad(of manager: MyDayManager) async {
        let loaded = expectation(description: "initial day loaded")
        let subscription = manager.$selectedDay
            .compactMap { $0 }
            .first()
            .sink { _ in loaded.fulfill() }
        await fulfillment(of: [loaded], timeout: 1)
        subscription.cancel()
    }
}
