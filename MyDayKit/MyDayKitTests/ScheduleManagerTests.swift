//
//  ScheduleManagerTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class ScheduleManagerTests: XCTestCase {

    // MARK: - Loading

    func test_load_deliversLocalAndRemoteSchedules() async {
        let (sut, _) = makeSUT(
            local: .success([.fixture(id: "phone")]),
            remote: .success([.fixture(id: "tablet")])
        )

        await sut.load()

        XCTAssertEqual(Set(sut.schedules.map(\.id)), ["phone", "tablet"])
    }

    // Being offline means stale, not broken. Blanking the local list here would take today's cards
    // away whenever there is no signal.
    func test_load_keepsLocalSchedulesWhenRemoteFails() async {
        let (sut, _) = makeSUT(local: .success([.fixture(id: "phone")]), remote: .failure(anyError))

        await sut.load()

        XCTAssertEqual(sut.schedules.map(\.id), ["phone"])
    }

    func test_load_deliversRemoteSchedulesWhenLocalFails() async {
        let (sut, _) = makeSUT(local: .failure(anyError), remote: .success([.fixture(id: "tablet")]))

        await sut.load()

        XCTAssertEqual(sut.schedules.map(\.id), ["tablet"])
    }

    func test_load_keepsAScheduleAlreadySaved() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(.fixture(id: "new"))

        await sut.load()

        XCTAssertEqual(sut.schedules.map(\.id), ["new"])
    }

    func test_loadIfNeeded_doesNotReadAgainOnceRemoteHasLoaded() async {
        let remote = ScheduleFetcherSpy(.success([]))
        let sut = ScheduleManager(saver: ScheduleUploaderSpy(), local: ScheduleFetcherStub(), remote: remote)

        await sut.loadIfNeeded()
        await sut.loadIfNeeded()

        XCTAssertEqual(remote.fetchCount, 1)
    }

    // Opened offline, the manager must try again next time. It outlives every screen, so otherwise it
    // would miss another device's schedules until relaunch.
    func test_loadIfNeeded_readsAgainAfterRemoteFailed() async {
        let remote = ScheduleFetcherSpy(.failure(anyError))
        let sut = ScheduleManager(saver: ScheduleUploaderSpy(), local: ScheduleFetcherStub(), remote: remote)

        await sut.loadIfNeeded()
        await sut.loadIfNeeded()

        XCTAssertEqual(remote.fetchCount, 2)
    }

    // MARK: - Saving

    func test_save_uploadsAndHoldsTheSchedule() async throws {
        let (sut, saver) = makeSUT()
        let expected = Schedule.fixture(updatedAt: fixedDate)

        try await sut.save(.fixture(updatedAt: fixedDate.addingTimeInterval(-60)))

        XCTAssertEqual(saver.receivedMessages, [.upload(expected)])
        XCTAssertEqual(sut.schedules, [expected])
    }

    // Local files store dates to the whole second. With a fraction here, the remote copy of this edit
    // would look newer than the local copy of the next edit in the same second, and would win.
    func test_save_stampsUpdatedAtInWholeSeconds() async throws {
        let (sut, _) = makeSUT(now: fixedDate.addingTimeInterval(0.75))

        try await sut.save(.fixture())

        XCTAssertEqual(sut.schedules.first?.updatedAt, fixedDate)
    }

    func test_save_replacesTheEarlierCopyOfAnEditedSchedule() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(.fixture(recurrence: .once(day: .fixture("2026-11-10"))))

        try await sut.save(.fixture(recurrence: .once(day: .fixture("2026-11-17"))))

        XCTAssertEqual(sut.schedules.map(\.recurrence), [.once(day: .fixture("2026-11-17"))])
    }

    // The sheet needs to see the failure, and a schedule that is not on disk must not show as if it
    // were.
    func test_save_throwsAndHoldsNothingWhenTheWriteFails() async {
        let (sut, saver) = makeSUT()
        saver.error = anyError

        do {
            try await sut.save(.fixture())
            XCTFail("Expected the save to throw")
        } catch {}

        XCTAssertEqual(sut.schedules, [])
    }

    // MARK: - Stopping

    func test_stop_writesTheScheduleWithStoppedAtRatherThanRemovingIt() async throws {
        let (sut, saver) = makeSUT()

        try await sut.stop(.fixture())

        XCTAssertEqual(saver.receivedMessages, [.upload(.fixture(updatedAt: fixedDate, stoppedAt: fixedDate))])
        XCTAssertEqual(sut.schedules.map(\.id), ["schedule"])
    }

    // MARK: - Reading

    func test_due_deliversOnlySchedulesDueThatDay() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(.fixture(id: "tuesdays"))
        try await sut.save(.fixture(id: "one-off", recurrence: .once(day: .fixture("2026-11-11"))))

        XCTAssertEqual(sut.due(on: .fixture("2026-11-10")).map(\.id), ["tuesdays"])
    }

    func test_due_leavesOutAStoppedSchedule() async throws {
        let (sut, _) = makeSUT()

        try await sut.stop(.fixture())

        XCTAssertEqual(sut.due(on: .fixture("2026-11-10")), [])
    }

    func test_active_leavesOutStoppedSchedulesAndFinishedOneOffs() async throws {
        let (sut, _) = makeSUT()
        try await sut.save(.fixture(id: "tuesdays"))
        try await sut.save(.fixture(id: "finished", recurrence: .once(day: .fixture("2026-11-01"))))
        try await sut.stop(.fixture(id: "stopped"))

        XCTAssertEqual(sut.active(on: .fixture("2026-11-08")).map(\.id), ["tuesdays"])
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)
    private let anyError = NSError(domain: "test", code: 0)

    private func makeSUT(
        local: Result<[Schedule], Error> = .success([]),
        remote: Result<[Schedule], Error> = .success([]),
        now: Date? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ScheduleManager, saver: ScheduleUploaderSpy) {
        let saver = ScheduleUploaderSpy()
        let localFetcher = ScheduleFetcherStub(local)
        let remoteFetcher = ScheduleFetcherStub(remote)
        let date = now ?? fixedDate
        let sut = ScheduleManager(saver: saver, local: localFetcher, remote: remoteFetcher, now: { date })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(saver, file: file, line: line)
        trackForMemoryLeaks(localFetcher, file: file, line: line)
        trackForMemoryLeaks(remoteFetcher, file: file, line: line)
        return (sut, saver)
    }
}
