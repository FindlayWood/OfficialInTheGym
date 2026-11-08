//
//  ScheduleMergeTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

final class ScheduleMergeTests: XCTestCase {

    // Local holds what has not synced, remote holds what was made on another device. Reading only one
    // would hide the other's schedules.
    func test_merged_deliversSchedulesFromBothSides() {
        let sut = Schedule.merged(local: [.fixture(id: "phone")], remote: [.fixture(id: "tablet")])

        XCTAssertEqual(Set(sut.map(\.id)), ["phone", "tablet"])
    }

    func test_merged_deliversLaterCopyOfTheSameSchedule() {
        let older = Schedule.fixture(updatedAt: fixedDate)
        let newer = Schedule.fixture(updatedAt: fixedDate.addingTimeInterval(60))

        XCTAssertEqual(Schedule.merged(local: [older], remote: [newer]), [newer])
        XCTAssertEqual(Schedule.merged(local: [newer], remote: [older]), [newer])
    }

    // Local files store dates to the whole second, so two quick edits tie. The local copy is the
    // second edit; letting remote win would undo it the next time the list loads.
    func test_merged_deliversLocalCopyOnATie() {
        let local = Schedule.fixture(updatedAt: fixedDate, stoppedAt: fixedDate)
        let remote = Schedule.fixture(updatedAt: fixedDate)

        XCTAssertEqual(Schedule.merged(local: [local], remote: [remote]), [local])
    }

    // This is why stopping keeps the document. If stopped schedules were dropped, the older remote
    // copy would be all that was left, and the card would return.
    func test_merged_keepsStoppedScheduleOverItsOlderCopy() {
        let stopped = Schedule.fixture(updatedAt: fixedDate.addingTimeInterval(60), stoppedAt: fixedDate)
        let older = Schedule.fixture(updatedAt: fixedDate)

        XCTAssertEqual(Schedule.merged(local: [stopped], remote: [older]), [stopped])
    }

    func test_merged_deliversOldestCreatedFirst() {
        let first = Schedule.fixture(id: "first", createdAt: fixedDate)
        let second = Schedule.fixture(id: "second", createdAt: fixedDate.addingTimeInterval(60))

        let sut = Schedule.merged(local: [second], remote: [first])

        XCTAssertEqual(sut.map(\.id), ["first", "second"])
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)
}
