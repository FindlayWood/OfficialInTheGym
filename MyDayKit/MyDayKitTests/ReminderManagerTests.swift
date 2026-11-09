//
//  ReminderManagerTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class ReminderManagerTests: XCTestCase {

    // MARK: - Settings

    func test_init_deliversStoredPreferences() {
        let (sut, _, store) = makeSUT(stored: checkInOn)

        XCTAssertEqual(sut.preferences, checkInOn)
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    func test_update_savesAndPlansWithTheNewPreferences() async {
        let (sut, scheduler, store) = makeSUT()

        sut.update(checkInOn)
        await sut.scheduling?.value

        XCTAssertEqual(store.receivedMessages, [.load, .save(checkInOn)])
        XCTAssertEqual(scheduler.receivedMessages.last.map(firstIdentifier), "reminder.checkIn.2026-11-10")
    }

    func test_update_doesNothingWhenPreferencesAreUnchanged() async {
        let (sut, scheduler, store) = makeSUT(stored: checkInOn)

        sut.update(checkInOn)
        await sut.scheduling?.value

        XCTAssertEqual(store.receivedMessages, [.load])
        XCTAssertTrue(scheduler.receivedMessages.isEmpty)
    }

    // MARK: - Today

    func test_refresh_plansFromTodayAsLoaded() async {
        let (sut, scheduler, _) = makeSUT(stored: checkInOn, today: .reminderFixture(date: now, checkedIn: true))

        await sut.refresh()
        await sut.scheduling?.value

        XCTAssertEqual(scheduler.receivedMessages.last.map(firstIdentifier), "reminder.checkIn.2026-11-11")
    }

    // Saving a check-in is what cancels that morning's reminder. If the manager ignored it, the
    // nudge would arrive after the check-in it asks for.
    func test_dayChanged_removesTodaysCheckInOnceCheckedIn() async {
        let (sut, scheduler, _) = makeSUT(stored: checkInOn)
        sut.update(ratingAndCheckInOn)

        sut.dayChanged(.reminderFixture(date: now, checkedIn: true))
        await sut.scheduling?.value

        XCTAssertEqual(scheduler.receivedMessages.last.map(firstIdentifier), "reminder.checkIn.2026-11-11")
    }

    func test_dayChanged_ignoresAnyDayButToday() async {
        let (sut, scheduler, _) = makeSUT(stored: checkInOn)
        let yesterday = now.addingTimeInterval(-86_400)

        sut.dayChanged(.reminderFixture(date: yesterday, checkedIn: true))
        await sut.scheduling?.value

        XCTAssertTrue(scheduler.receivedMessages.isEmpty)
    }

    // Every save on MyDay passes through here, most of them changing nothing a reminder reads.
    func test_dayChanged_doesNotPlanAgainWhenNothingRemindersReadChanged() async {
        let (sut, scheduler, _) = makeSUT(stored: checkInOn)

        sut.dayChanged(.reminderFixture(date: now, checkedIn: true))
        sut.dayChanged(.reminderFixture(date: now, checkedIn: true))
        await sut.scheduling?.value

        XCTAssertEqual(scheduler.receivedMessages.count, 1)
    }

    // Replacements are a remove and then an add. Run side by side, an older plan could land
    // after a newer one and bring back a reminder that had just been cancelled.
    func test_replans_runInTheOrderTheyWereMade() async {
        let (sut, scheduler, _) = makeSUT()

        sut.update(checkInOn)
        sut.dayChanged(.reminderFixture(date: now, checkedIn: true))
        await sut.scheduling?.value

        XCTAssertEqual(scheduler.receivedMessages.map(firstIdentifier), [
            "reminder.checkIn.2026-11-10",
            "reminder.checkIn.2026-11-11"
        ])
    }

    // MARK: - Sign out

    func test_stop_removesEveryReminder() async {
        let (sut, scheduler, _) = makeSUT(stored: checkInOn)

        await sut.stop()

        XCTAssertEqual(scheduler.receivedMessages, [.replace([])])
    }

    // MARK: - Helpers

    private func makeSUT(
        stored: ReminderPreferences = .default,
        today: MyDayFullDayModel? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ReminderManager, scheduler: ReminderSchedulerSpy, store: ReminderPreferencesStoreSpy) {
        let scheduler = ReminderSchedulerSpy()
        let store = ReminderPreferencesStoreSpy(stored: stored)
        let loader = MyDayLoaderStub(day: today)
        let permission = ReminderPermissionStub()
        let fixedNow = now
        let sut = ReminderManager(
            store: store,
            scheduler: scheduler,
            permission: permission,
            todayLoader: loader,
            now: { fixedNow },
            calendar: london
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(permission, file: file, line: line)
        return (sut, scheduler, store)
    }

    private func firstIdentifier(_ message: ReminderSchedulerSpy.Message) -> String? {
        switch message {
        case .replace(let identifiers): return identifiers.first
        }
    }

    private let london: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }()

    /// Tuesday 10 November 2026, 07:00 in London — before the morning reminder.
    private var now: Date {
        london.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 7))!
    }

    private var checkInOn: ReminderPreferences {
        var preferences = ReminderPreferences.default
        preferences.checkIn.isOn = true
        return preferences
    }

    private var ratingAndCheckInOn: ReminderPreferences {
        var preferences = checkInOn
        preferences.dayRating.isOn = true
        return preferences
    }
}
