//
//  TrackerHomeViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class TrackerHomeViewModelTests: XCTestCase {

    func test_load_asksForItsOwnKindAndDeliversNewestFirst() async {
        let spy = TrackerServicesSpy()
        let (old, new) = (session(id: "old", daysAgo: 5), session(id: "new", daysAgo: 1))
        spy.sessionsResult = .success([old, new])
        let sut = TrackerHomeViewModel(kind: .practice, loader: spy)

        await sut.load()

        XCTAssertEqual(spy.receivedMessages, [.loadSessions(.practice)])
        XCTAssertEqual(sut.sessions.map(\.id), ["new", "old"])
    }

    // The legacy screens kept a new session in a property nothing read, so it
    // only appeared after leaving the screen and coming back.
    func test_sessionRecorded_listsItFirstAndClosesTheSheet() async {
        let spy = TrackerServicesSpy()
        spy.sessionsResult = .success([session(id: "old", daysAgo: 5)])
        let sut = TrackerHomeViewModel(kind: .match, loader: spy)
        await sut.load()
        sut.recordNew()

        sut.sessionRecorded(session(id: "new", daysAgo: 0))

        XCTAssertEqual(sut.sessions.map(\.id), ["new", "old"])
        XCTAssertFalse(sut.isShowingNewEntry)
    }

    // MARK: - Helpers

    private func session(id: String, daysAgo: Double) -> TrackedSession {
        TrackedSession(id: id, date: .fixed.addingTimeInterval(-daysAgo * 86_400), ratings: TrackedSessionRatings(), notes: "",
                       workloadRatio: nil, mostRecentWorkload: nil, wellness: nil, cmj: nil)
    }
}
