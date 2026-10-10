//
//  JumpTestHistoryViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class JumpTestHistoryViewModelTests: XCTestCase {

    func test_sortedSessions_deliversNewestFirstByDefault() async {
        let (old, new) = (JumpTestSession.make(id: "old", daysAgo: 2, heights: [50]), JumpTestSession.make(id: "new", daysAgo: 0, heights: [30]))
        let sut = JumpTestHistoryViewModel(kind: .verticalJump, loader: JumpTestServicesSpy(sessionsResult: .success([old, new])))

        await sut.load()

        XCTAssertEqual(sut.sortedSessions.map(\.id), ["new", "old"])
    }

    func test_sortedSessions_deliversHighestBestFirstWhenSortedByHeight() async {
        let (old, new) = (JumpTestSession.make(id: "old", daysAgo: 2, heights: [50]), JumpTestSession.make(id: "new", daysAgo: 0, heights: [30, 35]))
        let sut = JumpTestHistoryViewModel(kind: .verticalJump, loader: JumpTestServicesSpy(sessionsResult: .success([new, old])))
        await sut.load()

        sut.sortByDate(false)

        XCTAssertEqual(sut.sortedSessions.map(\.id), ["old", "new"])
    }

    func test_load_keepsNothingAndStopsLoadingOnFailure() async {
        let sut = JumpTestHistoryViewModel(kind: .verticalJump, loader: JumpTestServicesSpy(sessionsResult: .failure(NSError(domain: "test", code: 0))))

        await sut.load()

        XCTAssertEqual(sut.sessions, [])
        XCTAssertFalse(sut.isLoading)
    }
}
