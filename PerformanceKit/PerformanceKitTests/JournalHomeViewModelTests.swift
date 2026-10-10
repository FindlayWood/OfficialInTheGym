//
//  JournalHomeViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class JournalHomeViewModelTests: XCTestCase {

    func test_load_deliversTheLoadersEntries() async {
        let entries = [JournalEntry.make(id: "b"), .make(id: "a")]
        let sut = JournalHomeViewModel(loader: JournalServicesSpy(loadResult: .success(entries)))

        await sut.load()

        XCTAssertEqual(sut.entries, entries)
        XCTAssertFalse(sut.isLoading)
    }

    func test_load_keepsNothingAndStopsLoadingOnFailure() async {
        let sut = JournalHomeViewModel(loader: JournalServicesSpy(loadResult: .failure(anyError)))

        await sut.load()

        XCTAssertEqual(sut.entries, [])
        XCTAssertFalse(sut.isLoading)
    }

    func test_todayEntries_deliversOnlyEntriesFromToday() async {
        let today = JournalEntry.make(id: "today", date: .fixed)
        let older = JournalEntry.make(id: "older", date: .fixed.addingTimeInterval(-3 * 86_400))
        let sut = JournalHomeViewModel(
            loader: JournalServicesSpy(loadResult: .success([today, older])),
            isToday: { $0 == .fixed }
        )

        await sut.load()

        XCTAssertEqual(sut.todayEntries, [today])
    }

    // The screen loads every time it appears. The legacy view model appended
    // today's entries to a list of their own on each load, so coming back to the
    // journal showed every one of today's entries twice.
    func test_todayEntries_doesNotRepeatAfterASecondLoad() async {
        let today = JournalEntry.make(id: "today", date: .fixed)
        let sut = JournalHomeViewModel(loader: JournalServicesSpy(loadResult: .success([today])), isToday: { _ in true })

        await sut.load()
        await sut.load()

        XCTAssertEqual(sut.todayEntries, [today])
    }

    func test_entryAdded_putsTheNewEntryFirst() async {
        let existing = JournalEntry.make(id: "old")
        let new = JournalEntry.make(id: "new")
        let sut = JournalHomeViewModel(loader: JournalServicesSpy(loadResult: .success([existing])))
        await sut.load()

        sut.entryAdded(new)

        XCTAssertEqual(sut.entries, [new, existing])
    }

    // MARK: - Helpers

    private var anyError: NSError { NSError(domain: "test", code: 0) }
}
