//
//  InjuryManagerTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class InjuryManagerTests: XCTestCase {

    // MARK: - Loading

    func test_load_deliversLocalAndRemoteInjuries() async {
        let (sut, _) = makeSUT(local: .success([.fixture(id: "phone")]), remote: .success([.fixture(id: "tablet")]))

        await sut.load()

        XCTAssertEqual(Set(sut.injuries.map(\.id)), ["phone", "tablet"])
    }

    // An injury has to be rated with no signal. Offline means stale, not broken.
    func test_load_keepsLocalInjuriesWhenRemoteFails() async {
        let (sut, saver) = makeSUT(local: .success([.fixture(id: "phone")]), remote: .failure(anyNSError()))

        await sut.load()

        XCTAssertEqual(sut.injuries.map(\.id), ["phone"])
        XCTAssertTrue(saver.receivedMessages.isEmpty)
    }

    // Firestore holds one document per injury, replaced on every save. Without writing the merge
    // back, the day only this phone rated would never reach it.
    func test_load_writesBackAMergeTheRemoteCopyIsMissing() async {
        let local = Injury.fixture(checkIns: ["2026-11-10": .fixture(pain: 4)], updatedAt: Date(timeIntervalSince1970: 100))
        let remote = Injury.fixture(checkIns: ["2026-11-11": .fixture(pain: 2)], updatedAt: Date(timeIntervalSince1970: 200))
        let (sut, saver) = makeSUT(local: .success([local]), remote: .success([remote]))

        await sut.load()

        XCTAssertEqual(saver.uploaded.map { $0.checkIns.keys.sorted() }, [["2026-11-10", "2026-11-11"]])
    }

    func test_load_writesNothingBackWhenBothCopiesAgree() async {
        let injury = Injury.fixture(checkIns: ["2026-11-10": .fixture()])
        let (sut, saver) = makeSUT(local: .success([injury]), remote: .success([injury]))

        await sut.load()

        XCTAssertTrue(saver.receivedMessages.isEmpty)
    }

    // MARK: - Writing

    func test_add_savesANewInjuryStampedNow() async throws {
        let (sut, saver) = makeSUT()

        try await sut.add(region: .knee, side: .right, startedOn: .fixture("2026-11-09"), note: "  Twisted it  ")

        let saved = try XCTUnwrap(saver.uploaded.first)
        XCTAssertEqual(saved.title, "Right knee")
        XCTAssertEqual(saved.startedOn, .fixture("2026-11-09"))
        XCTAssertEqual(saved.note, "Twisted it")
        XCTAssertEqual(saved.updatedAt, fixedNow)
        XCTAssertEqual(sut.active(on: .fixture("2026-11-10")).map(\.id), [saved.id])
    }

    func test_add_storesNoNoteForBlankText() async throws {
        let (sut, saver) = makeSUT()

        try await sut.add(region: .calf, side: .left, startedOn: .fixture("2026-11-10"), note: "   ")

        XCTAssertNil(saver.uploaded.first?.note)
    }

    // One check-in per injury per day: a second save that day corrects the first.
    func test_checkIn_replacesThatDaysEarlierCheckIn() async throws {
        let (sut, saver) = try await makeLoadedSUT(with: .fixture())

        try await sut.checkIn(.fixture(), pain: 5, impact: .modified, on: .fixture("2026-11-10"))
        try await sut.checkIn(.fixture(), pain: 3, impact: .none, on: .fixture("2026-11-10"))

        let latest = try XCTUnwrap(saver.uploaded.last)
        XCTAssertEqual(latest.checkIns.count, 1)
        XCTAssertEqual(latest.checkIn(on: .fixture("2026-11-10"))?.pain, 3)
        XCTAssertEqual(latest.checkIn(on: .fixture("2026-11-10"))?.impact, InjuryImpact.none)
    }

    // A row drawn before an earlier check-in landed holds a stale injury. Checking in from it
    // must keep what is already held, not write the stale copy over it.
    func test_checkIn_keepsCheckInsHeldSinceTheRowWasDrawn() async throws {
        let (sut, saver) = try await makeLoadedSUT(with: .fixture(checkIns: ["2026-11-09": .fixture(pain: 6)]))

        try await sut.checkIn(.fixture(), pain: 4, impact: .modified, on: .fixture("2026-11-10"))

        XCTAssertEqual(saver.uploaded.last?.checkIns.keys.sorted(), ["2026-11-09", "2026-11-10"])
    }

    func test_resolve_takesItOffMyDayFromThatDay() async throws {
        let (sut, _) = try await makeLoadedSUT(with: .fixture(startedOn: "2026-11-08"))

        try await sut.resolve(.fixture(), on: .fixture("2026-11-10"))

        XCTAssertEqual(sut.active(on: .fixture("2026-11-09")).count, 1)
        XCTAssertTrue(sut.active(on: .fixture("2026-11-10")).isEmpty)
    }

    func test_remove_marksRatherThanDeletes() async throws {
        let (sut, saver) = try await makeLoadedSUT(with: .fixture())

        try await sut.remove(.fixture())

        XCTAssertNotNil(saver.uploaded.last?.removedAt)
        XCTAssertEqual(sut.injuries.count, 1)
        XCTAssertTrue(sut.active(on: .fixture("2026-11-10")).isEmpty)
    }

    func test_save_failureLeavesTheHeldInjuriesUnchanged() async {
        let (sut, saver) = makeSUT()
        saver.error = anyNSError()

        _ = try? await sut.add(region: .knee, side: .left, startedOn: .fixture("2026-11-10"), note: nil)

        XCTAssertTrue(sut.injuries.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        local: Result<[Injury], Error> = .success([]),
        remote: Result<[Injury], Error> = .success([]),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: InjuryManager, saver: InjuryUploaderSpy) {
        let saver = InjuryUploaderSpy()
        let localFetcher = InjuryFetcherStub(local)
        let remoteFetcher = InjuryFetcherStub(remote)
        let now = fixedNow
        let sut = InjuryManager(saver: saver, local: localFetcher, remote: remoteFetcher, now: { now })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(saver, file: file, line: line)
        trackForMemoryLeaks(localFetcher, file: file, line: line)
        trackForMemoryLeaks(remoteFetcher, file: file, line: line)
        return (sut, saver)
    }

    /// Loaded with `injury` held in both copies, so nothing is written back and the spy starts
    /// empty.
    private func makeLoadedSUT(
        with injury: Injury,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> (sut: InjuryManager, saver: InjuryUploaderSpy) {
        let (sut, saver) = makeSUT(local: .success([injury]), remote: .success([injury]), file: file, line: line)
        await sut.load()
        XCTAssertTrue(saver.receivedMessages.isEmpty, file: file, line: line)
        return (sut, saver)
    }

    private let fixedNow = Date(timeIntervalSince1970: 1_900_000_000)
}
