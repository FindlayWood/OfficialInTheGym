//
//  PerformanceHomeViewModelTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

@MainActor
final class PerformanceHomeViewModelTests: XCTestCase {

    func test_tools_deliversEveryToolInOrderForYourOwnCentre() {
        let sut = PerformanceHomeViewModel(currentUserId: "me", athleteId: "me")

        XCTAssertEqual(sut.tools, [.matchTracker, .practiceTracker, .workload, .verticalJump, .journal])
    }

    // A coach opening an athlete's centre must not see the athlete's journal.
    // Without the filter, it is listed and opens someone else's private entries.
    func test_tools_deliversEverythingButTheJournalForSomeoneElsesCentre() {
        let sut = PerformanceHomeViewModel(currentUserId: "coach", athleteId: "athlete")

        XCTAssertEqual(sut.tools, [.matchTracker, .practiceTracker, .workload, .verticalJump])
    }

    func test_select_forwardsTheTool() {
        let sut = PerformanceHomeViewModel(currentUserId: "me", athleteId: "me")
        var selected: [PerformanceTool] = []
        sut.onSelectTool = { selected.append($0) }

        sut.select(.verticalJump)

        XCTAssertEqual(selected, [.verticalJump])
    }
}
