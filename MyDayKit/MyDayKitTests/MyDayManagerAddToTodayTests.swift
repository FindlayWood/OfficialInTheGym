//
//  MyDayManagerAddToTodayTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 11/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class MyDayManagerAddToTodayTests: XCTestCase {

    // MARK: - Today open

    func test_addingWorkoutToToday_appendsToTheOpenDayWhenItIsToday() async {
        let (sut, saver) = await makeSUT(today: makeDay(id: "today", date: Date()))

        await sut.addingWorkoutToToday(.fixture())

        XCTAssertEqual(sut.selectedDay?.workouts.map(\.template.id), ["template"])
        XCTAssertEqual(saver.receivedMessages, [.save(dayId: "today", workoutTemplateIds: ["template"])])
    }

    // MARK: - Another day open

    // The bug this replaced: the workout went onto whatever day was open, and the day-file saver,
    // which names its file by today's date, wrote that past day over today's file.
    func test_addingWorkoutToToday_savesTodayNotThePastDayOnScreen() async {
        let (sut, saver) = await makeSUT(today: makeDay(id: "today", date: Date()))
        sut.selectedDay = makeDay(id: "past", date: twoDaysAgo)

        await sut.addingWorkoutToToday(.fixture())

        XCTAssertEqual(saver.receivedMessages, [.save(dayId: "today", workoutTemplateIds: ["template"])])
        XCTAssertEqual(sut.selectedDay?.id, "past")
        XCTAssertEqual(sut.selectedDay?.workouts.count, 0)
    }

    // An empty day saved over a real one, because a load failed, would lose everything logged on it.
    func test_addingWorkoutToToday_savesNothingWhenTodayCannotBeLoaded() async {
        let (sut, saver) = await makeSUT(today: nil, loadError: anyNSError())
        sut.selectedDay = makeDay(id: "past", date: twoDaysAgo)

        await sut.addingWorkoutToToday(.fixture())

        XCTAssertEqual(saver.receivedMessages, [])
    }

    func test_addingWorkoutToToday_startsANewDayWhenTodayHasNoDocument() async {
        let (sut, saver) = await makeSUT(today: nil)
        sut.selectedDay = makeDay(id: "past", date: twoDaysAgo)

        await sut.addingWorkoutToToday(.fixture())

        XCTAssertEqual(saver.receivedMessages.count, 1)
        guard case let .save(dayId, templateIds)? = saver.receivedMessages.first else { return }
        XCTAssertNotEqual(dayId, "past")
        XCTAssertEqual(templateIds, ["template"])
    }

    // The reminder planner hears about every save through `onDayChanged`, which `selectedDay`'s
    // `didSet` fires. Saving today while another day is open bypasses that, so it must fire by hand.
    func test_addingWorkoutToToday_reportsTodayAsChangedWhenAnotherDayIsOpen() async {
        let (sut, _) = await makeSUT(today: makeDay(id: "today", date: Date()))
        sut.selectedDay = makeDay(id: "past", date: twoDaysAgo)
        var changedDayIds: [String] = []
        sut.onDayChanged = { changedDayIds.append($0.id) }

        await sut.addingWorkoutToToday(.fixture())

        XCTAssertEqual(changedDayIds, ["today"])
    }

    // MARK: - Helpers

    private var twoDaysAgo: Date { Date().addingTimeInterval(-86_400 * 2) }

    private func makeDay(id: String, date: Date) -> MyDayFullDayModel {
        MyDayFullDayModel(id: id, date: date, exercises: [], workouts: [])
    }

    private func makeSUT(
        today: MyDayFullDayModel?,
        loadError: Error? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> (sut: MyDayManager, saver: MyDaySaverSpy) {
        let saver = MyDaySaverSpy()
        let sut = MyDayManager(
            saver: PreviewSaver(),
            clipSaver: PreviewMyDaySaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: MyDayLoaderStub(day: today, error: loadError),
            deleter: PreviewMyDayDeleter(),
            wellnessSaver: PreviewMyDaySaver(),
            rpeSaver: PreviewMyDaySaver(),
            workoutSaver: saver,
            workoutStatsSaver: PreviewExerciseStatsSaver(),
            completedSessionSaver: PreviewCompletedWorkoutSessionSaver(),
            completedSessionDeleter: PreviewCompletedWorkoutSessionDeleter()
        )
        await waitForInitialLoad(of: sut)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(saver, file: file, line: line)
        return (sut, saver)
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
