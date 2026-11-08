//
//  ScheduleTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

final class ScheduleTests: XCTestCase {

    func test_isDue_deliversTrueOnADayTheRecurrenceFallsOn() {
        let sut = makeSchedule()

        XCTAssertTrue(sut.isDue(on: .fixture("2026-11-10")))
        XCTAssertFalse(sut.isDue(on: .fixture("2026-11-11")))
    }

    // Stopping keeps the document, so it must take the card away by itself. A deleted schedule would
    // come straight back from the remote copy when the two are merged.
    func test_isDue_deliversFalseOnceStopped() {
        let sut = makeSchedule(stoppedAt: fixedDate)

        XCTAssertFalse(sut.isDue(on: .fixture("2026-11-10")))
    }

    func test_nextDue_deliversNextDayWhileActive() {
        let sut = makeSchedule()

        XCTAssertEqual(sut.nextDue(onOrAfter: .fixture("2026-11-11")), .fixture("2026-11-17"))
    }

    func test_nextDue_deliversNilOnceStopped() {
        let sut = makeSchedule(stoppedAt: fixedDate)

        XCTAssertNil(sut.nextDue(onOrAfter: .fixture("2026-11-10")))
    }

    func test_nextDue_deliversNilForFinishedOneOff() {
        let sut = makeSchedule(recurrence: .once(day: .fixture("2026-11-10")))

        XCTAssertNil(sut.nextDue(onOrAfter: .fixture("2026-11-11")))
    }

    func test_codable_deliversSameScheduleForWorkout() throws {
        let sut = makeSchedule(item: .workout(templateId: "template"))

        XCTAssertEqual(try roundTrip(sut), sut)
    }

    func test_codable_deliversSameScheduleForSport() throws {
        let sut = makeSchedule(item: .sport(sport: .basketball, duration: 5_400), stoppedAt: fixedDate)

        XCTAssertEqual(try roundTrip(sut), sut)
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)

    private func makeSchedule(
        item: ScheduleItem = .workout(templateId: "template"),
        recurrence: ScheduleRecurrence = .weekly(weekdays: [.tuesday], start: .fixture("2026-11-09")),
        stoppedAt: Date? = nil
    ) -> Schedule {
        Schedule(
            id: "schedule",
            item: item,
            recurrence: recurrence,
            createdAt: fixedDate,
            updatedAt: fixedDate,
            stoppedAt: stoppedAt
        )
    }

    private func roundTrip(_ schedule: Schedule) throws -> Schedule {
        try JSONDecoder().decode(Schedule.self, from: JSONEncoder().encode(schedule))
    }
}
