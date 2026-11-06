//
//  MyDaySportManagerTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import Combine
import XCTest
@testable import MyDayKit

@MainActor
final class MyDaySportManagerTests: XCTestCase {

    func test_add_putsSessionOnSelectedDay() async {
        let (sut, _, _) = await makeSUT()

        await sut.add(.basketballGame())

        XCTAssertEqual(sut.sessions, [.basketballGame()])
    }

    // The composed saver is told the day as it now stands, so the day it
    // writes already holds the session it is also writing on its own.
    func test_add_savesDayHoldingSessionWithSession() async {
        let (sut, _, saver) = await makeSUT()

        await sut.add(.golfRound())
        await sut.add(.basketballGame())

        XCTAssertEqual(saver.receivedMessages, [
            .add(daySportIds: ["golf"], session: .golfRound()),
            .add(daySportIds: ["golf", "game"], session: .basketballGame())
        ])
    }

    // The day file saver names its file by the date it saves on. A session
    // added while a past day is selected would overwrite today's file with
    // that past day's contents.
    func test_add_doesNothingOnPastDay() async {
        let (sut, dayManager, saver) = await makeSUT()
        dayManager.selectedDay = MyDayFullDayModel(id: "past", date: yesterday(), exercises: [], workouts: [])

        await sut.add(.basketballGame())

        XCTAssertEqual(sut.sessions, [])
        XCTAssertEqual(saver.receivedMessages, [])
    }

    func test_add_keepsSessionOnDayWhenSaveFails() async {
        let (sut, _, saver) = await makeSUT()
        saver.error = anyError

        await sut.add(.basketballGame())

        XCTAssertEqual(sut.sessions, [.basketballGame()])
    }

    func test_remove_takesSessionOffDayAndSavesWithoutIt() async {
        let (sut, _, saver) = await makeSUT()
        await sut.add(.golfRound())
        await sut.add(.basketballGame())

        await sut.remove(.golfRound())

        XCTAssertEqual(sut.sessions, [.basketballGame()])
        XCTAssertEqual(saver.receivedMessages.last, .remove(daySportIds: ["game"], sessionId: "golf"))
    }

    // A remove for a session not on the day would still delete a document of
    // that id — one that may belong to another day.
    func test_remove_doesNothingForSessionNotOnDay() async {
        let (sut, _, saver) = await makeSUT()

        await sut.remove(.golfRound())

        XCTAssertEqual(saver.receivedMessages, [])
    }

    func test_remove_doesNothingOnPastDay() async {
        let (sut, dayManager, saver) = await makeSUT()
        dayManager.selectedDay = MyDayFullDayModel(
            id: "past", date: yesterday(), exercises: [], workouts: [], sports: [.golfRound()]
        )

        await sut.remove(.golfRound())

        XCTAssertEqual(sut.sessions, [.golfRound()])
        XCTAssertEqual(saver.receivedMessages, [])
    }

    // MARK: - Helpers

    private let anyError = NSError(domain: "test", code: 0)

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> (sut: MyDaySportManager, dayManager: MyDayManager, saver: MyDayAndSportSessionSaverSpy) {
        let dayManager = MyDayManager(
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
        await waitForInitialLoad(of: dayManager)
        let saver = MyDayAndSportSessionSaverSpy()
        let sut = MyDaySportManager(dayManager: dayManager, saver: saver)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(dayManager, file: file, line: line)
        trackForMemoryLeaks(saver, file: file, line: line)
        return (sut, dayManager, saver)
    }

    /// `MyDayManager.init` loads today in a `Task`. Waiting for it means that load cannot land
    /// after a test has set the day itself and overwrite it.
    private func waitForInitialLoad(of dayManager: MyDayManager) async {
        let loaded = expectation(description: "initial day loaded")
        let subscription = dayManager.$selectedDay
            .compactMap { $0 }
            .first()
            .sink { _ in loaded.fulfill() }
        await fulfillment(of: [loaded], timeout: 1)
        subscription.cancel()
    }

    private func yesterday() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    }
}
