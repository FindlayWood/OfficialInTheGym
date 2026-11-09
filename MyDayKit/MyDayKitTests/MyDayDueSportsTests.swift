//
//  MyDayDueSportsTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayDueSportsTests: XCTestCase {

    // MARK: - Due

    func test_dueSports_deliversASportDueThatDayWithItsUsualTime() {
        let sut = makeDay().dueSports(schedules: [basketball()], calendar: london)

        XCTAssertEqual(sut, [ScheduledSport(scheduleId: "schedule", day: .fixture("2026-11-10"), sport: .basketball, duration: 5_400)])
    }

    func test_dueSports_deliversNothingOnADayItDoesNotFallOn() {
        let sut = makeDay().dueSports(
            schedules: [basketball(recurrence: .weekly(weekdays: [.thursday], start: .fixture("2026-11-09")))],
            calendar: london
        )

        XCTAssertEqual(sut, [])
    }

    func test_dueSports_leavesOutWorkouts() {
        let sut = makeDay().dueSports(schedules: [.fixture()], calendar: london)

        XCTAssertEqual(sut, [])
    }

    // MARK: - Hidden

    func test_dueSports_leavesOutASessionAlreadyLoggedFromTheSchedule() {
        let item = ScheduledSport(scheduleId: "schedule", day: .fixture("2026-11-10"), sport: .basketball, duration: 5_400)
        let day = makeDay().addingSport(item.makeEntry(duration: 5_400, rpe: 7, performedAt: tuesday))

        XCTAssertEqual(day.dueSports(schedules: [basketball()], calendar: london), [])
    }

    // A game logged the normal way is the session the schedule meant. A card still asking for it would
    // read as unfinished.
    func test_dueSports_leavesOutASportLoggedByHand() {
        let day = makeDay().addingSport(.basketballGame())

        XCTAssertEqual(day.dueSports(schedules: [basketball()], calendar: london), [])
    }

    func test_dueSports_keepsADifferentSportLoggedByHand() {
        let day = makeDay().addingSport(.golfRound())

        XCTAssertEqual(day.dueSports(schedules: [basketball()], calendar: london).count, 1)
    }

    func test_dueSports_leavesOutAScheduleSkippedToday() {
        let day = makeDay().skippingSchedule("schedule")

        XCTAssertEqual(day.dueSports(schedules: [basketball()], calendar: london), [])
    }

    func test_dueSports_leavesOutAStoppedSchedule() {
        let stopped = basketball(stoppedAt: tuesday)

        XCTAssertEqual(makeDay().dueSports(schedules: [stopped], calendar: london), [])
    }

    // Logged by mistake, the session comes off and the card returns, so it can be logged properly.
    func test_dueSports_comesBackWhenTheLoggedSessionIsRemoved() {
        let item = ScheduledSport(scheduleId: "schedule", day: .fixture("2026-11-10"), sport: .basketball, duration: 5_400)
        let entry = item.makeEntry(duration: 5_400, rpe: 7, performedAt: tuesday)

        let day = makeDay().addingSport(entry).removingSport(id: entry.id)

        XCTAssertEqual(day.dueSports(schedules: [basketball()], calendar: london), [item])
    }

    // MARK: - Done

    func test_makeEntry_recordsATrainingSessionWithTheTimeAndEffortGiven() {
        let item = ScheduledSport(scheduleId: "schedule", day: .fixture("2026-11-10"), sport: .basketball, duration: 5_400)

        let sut = item.makeEntry(duration: 3_600, rpe: 8, performedAt: tuesday)

        XCTAssertEqual(sut.sport, .basketball)
        XCTAssertEqual(sut.sessionType, .training)
        XCTAssertEqual(sut.duration, 3_600)
        XCTAssertEqual(sut.rpe, 8)
        XCTAssertEqual(sut.performedAt, tuesday)
        XCTAssertEqual(sut.scheduleId, "schedule")
        XCTAssertNotNil(sut.sessionLoad)
    }

    // A second press, or a press on another device, must correct the one session. A fresh id would add
    // a second one to the day and to stats.
    func test_makeEntry_deliversTheSameIdForTheSameDay() {
        let item = ScheduledSport(scheduleId: "schedule", day: .fixture("2026-11-10"), sport: .basketball, duration: 5_400)
        let day = makeDay()
            .addingSport(item.makeEntry(duration: 5_400, rpe: 7, performedAt: tuesday))
            .addingSport(item.makeEntry(duration: 3_600, rpe: 8, performedAt: tuesday))

        XCTAssertEqual(day.sports?.map(\.rpe), [8])
    }

    // MARK: - Codable

    // Every sport session written so far has no `scheduleId`. A non-optional field would fail to decode
    // every day holding one.
    func test_decode_readsASessionWrittenBeforeSchedulesExisted() throws {
        let data = try JSONEncoder().encode(SportSessionEntry.basketballGame())

        let sut = try JSONDecoder().decode(SportSessionEntry.self, from: data)

        XCTAssertNil(sut.scheduleId)
    }

    // MARK: - Helpers

    /// Tuesday 10 November 2026, midday in London.
    private let tuesday = Date(timeIntervalSince1970: 1_794_312_000)

    private var london: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }

    private func basketball(
        recurrence: ScheduleRecurrence = .weekly(weekdays: [.tuesday, .thursday], start: .fixture("2026-11-09")),
        stoppedAt: Date? = nil
    ) -> Schedule {
        Schedule(
            id: "schedule",
            item: .sport(sport: .basketball, duration: 5_400),
            recurrence: recurrence,
            createdAt: tuesday,
            updatedAt: tuesday,
            stoppedAt: stoppedAt
        )
    }

    private func makeDay() -> MyDayFullDayModel {
        MyDayFullDayModel(id: "day", date: tuesday, exercises: [], workouts: [])
    }
}
