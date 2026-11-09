//
//  ScheduleFormModelTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class ScheduleFormModelTests: XCTestCase {

    // MARK: - New schedule

    func test_init_startsAsAOneOffTomorrow() {
        let (sut, _) = makeSUT()

        XCTAssertEqual(sut.recurrence, .once(day: .fixture("2026-11-11")))
        XCTAssertEqual(sut.nextText, "Next: Tomorrow")
        XCTAssertTrue(sut.canSave)
    }

    // A preselected weekday would count as chosen when the user never chose it, and a card would
    // appear on that day.
    func test_recurrence_deliversNilUntilARepeatHasAWeekday() {
        let (sut, _) = makeSUT()

        sut.repeats = true

        XCTAssertNil(sut.recurrence)
        XCTAssertEqual(sut.nextText, "Pick at least one day")
        XCTAssertFalse(sut.canSave)
    }

    func test_recurrence_deliversWeeklyFromToday() {
        let (sut, _) = makeSUT()

        sut.repeats = true
        sut.toggle(.thursday)
        sut.toggle(.tuesday)

        XCTAssertEqual(sut.recurrence, .weekly(weekdays: [.tuesday, .thursday], start: today))
    }

    func test_toggle_removesAWeekdayAlreadyPicked() {
        let (sut, _) = makeSUT()

        sut.toggle(.tuesday)
        sut.toggle(.tuesday)

        XCTAssertEqual(sut.weekdays, [])
    }

    func test_nextText_saysToday_whenTodaysWeekdayIsPicked() {
        let (sut, _) = makeSUT()

        sut.repeats = true
        sut.toggle(.tuesday)

        XCTAssertEqual(sut.nextText, "Next: Today")
    }

    // MARK: - Every two weeks

    func test_recurrence_startsThisWeekFromToday() {
        let (sut, _) = makeSUT()

        sut.repeats = true
        sut.frequency = .everyTwoWeeks
        sut.toggle(.friday)

        XCTAssertEqual(sut.recurrence, .everyTwoWeeks(weekdays: [.friday], start: today))
        XCTAssertEqual(sut.nextText, "Next: Fri 13 Nov")
    }

    func test_recurrence_startsNextWeekFromItsMonday() {
        let (sut, _) = makeSUT()

        sut.repeats = true
        sut.frequency = .everyTwoWeeks
        sut.firstWeek = .next
        sut.toggle(.friday)

        XCTAssertEqual(sut.recurrence, .everyTwoWeeks(weekdays: [.friday], start: .fixture("2026-11-16")))
        XCTAssertEqual(sut.nextText, "Next: Fri 20 Nov")
    }

    // The day has gone this week and next week is off, so the sheet must say so before Save rather
    // than leave the user expecting a card next Monday.
    func test_nextText_skipsTheOffWeek_whenThePickedDayHasPassedThisWeek() {
        let (sut, _) = makeSUT()

        sut.repeats = true
        sut.frequency = .everyTwoWeeks
        sut.toggle(.monday)

        XCTAssertEqual(sut.nextText, "Next: Mon 23 Nov")
    }

    // MARK: - Editing

    func test_init_seedsEachAnswerFromTheScheduleBeingEdited() {
        let (sut, _) = makeSUT(editing: .fixture(recurrence: .weekly(weekdays: [.monday, .friday], start: today)))

        XCTAssertTrue(sut.isEditing)
        XCTAssertTrue(sut.repeats)
        XCTAssertEqual(sut.frequency, .weekly)
        XCTAssertEqual(sut.weekdays, [.monday, .friday])
    }

    func test_init_seedsTheDateOfAOneOff() {
        let (sut, _) = makeSUT(editing: .fixture(recurrence: .once(day: .fixture("2026-12-25"))))

        XCTAssertFalse(sut.repeats)
        XCTAssertEqual(sut.recurrence, .once(day: .fixture("2026-12-25")))
    }

    // Saving rebuilds `start` from the "this week / next week" answer. Seeded wrongly, opening a
    // schedule and pressing Save without changing anything would swap which weeks it falls on.
    func test_editing_keepsTheSameWeeksOfAnEveryTwoWeeksSchedule() throws {
        for start in ["2026-10-27", "2026-11-03", "2026-11-10", "2026-11-16"] {
            let original = ScheduleRecurrence.everyTwoWeeks(weekdays: [.friday], start: .fixture(start))
            let (sut, _) = makeSUT(editing: .fixture(recurrence: original))

            let saved = try XCTUnwrap(sut.recurrence, "start \(start)")

            XCTAssertEqual(
                saved.nextOccurrence(onOrAfter: today),
                original.nextOccurrence(onOrAfter: today),
                "start \(start)"
            )
        }
    }

    // MARK: - Saving

    func test_save_writesANewScheduleForTheItem() async throws {
        let (sut, saver) = makeSUT(item: .sport(sport: .basketball, duration: 5_400))

        let saved = await sut.save()

        XCTAssertTrue(saved)
        guard case .upload(let schedule) = try XCTUnwrap(saver.receivedMessages.first) else { return }
        XCTAssertEqual(schedule.item, .sport(sport: .basketball, duration: 5_400))
        XCTAssertEqual(schedule.recurrence, .once(day: .fixture("2026-11-11")))
        XCTAssertEqual(schedule.createdAt, fixedDate)
    }

    func test_save_keepsTheIdentityOfAScheduleBeingEdited() async throws {
        let original = Schedule.fixture(id: "existing", createdAt: fixedDate.addingTimeInterval(-60))
        let (sut, saver) = makeSUT(editing: original)
        sut.toggle(.friday)

        _ = await sut.save()

        guard case .upload(let schedule) = try XCTUnwrap(saver.receivedMessages.first) else { return }
        XCTAssertEqual(schedule.id, "existing")
        XCTAssertEqual(schedule.createdAt, original.createdAt)
        XCTAssertEqual(schedule.recurrence, .weekly(weekdays: [.tuesday, .friday], start: today))
    }

    func test_save_writesNothingWithoutAnAnswer() async {
        let (sut, saver) = makeSUT()
        sut.repeats = true

        let saved = await sut.save()

        XCTAssertFalse(saved)
        XCTAssertEqual(saver.receivedMessages, [])
    }

    // The sheet stays open with the answers intact, since they are what the user needs to retry.
    func test_save_reportsAFailureAndKeepsTheAnswers() async {
        let (sut, saver) = makeSUT()
        saver.error = NSError(domain: "test", code: 0)
        sut.repeats = true
        sut.toggle(.friday)

        let saved = await sut.save()

        XCTAssertFalse(saved)
        XCTAssertNotNil(sut.saveError)
        XCTAssertEqual(sut.weekdays, [.friday])
        XCTAssertFalse(sut.isSaving)
    }

    // A one-off whose date has gone has no next day. Saving it would be a schedule that never appears.
    func test_canSave_deliversFalseForAOneOffAlreadyPassed() {
        let (sut, _) = makeSUT(editing: .fixture(recurrence: .once(day: .fixture("2026-11-01"))))

        XCTAssertFalse(sut.canSave)
        XCTAssertEqual(sut.nextText, "This date has passed")
    }

    // MARK: - Stopping

    func test_stop_writesTheScheduleBeingEditedAsStopped() async throws {
        let (sut, saver) = makeSUT(editing: .fixture(id: "existing"))

        let stopped = await sut.stop()

        XCTAssertTrue(stopped)
        guard case .upload(let schedule) = try XCTUnwrap(saver.receivedMessages.first) else { return }
        XCTAssertEqual(schedule.id, "existing")
        XCTAssertNotNil(schedule.stoppedAt)
    }

    func test_stop_doesNothingForANewSchedule() async {
        let (sut, saver) = makeSUT()

        let stopped = await sut.stop()

        XCTAssertFalse(stopped)
        XCTAssertEqual(saver.receivedMessages, [])
    }

    // MARK: - Helpers

    /// Tuesday 10 November 2026, midday in London.
    private let fixedDate = Date(timeIntervalSince1970: 1_794_312_000)
    private let today = ScheduleDay.fixture("2026-11-10")

    private var london: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }

    private func makeSUT(
        item: ScheduleItem = .workout(templateId: "template"),
        editing: Schedule? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ScheduleFormModel, saver: ScheduleUploaderSpy) {
        let saver = ScheduleUploaderSpy()
        let date = fixedDate
        let manager = ScheduleManager(saver: saver, local: ScheduleFetcherStub(), remote: ScheduleFetcherStub(), now: { date })
        let sut = ScheduleFormModel(title: "Monday Upper", item: item, editing: editing, manager: manager, now: { date }, calendar: london)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(manager, file: file, line: line)
        trackForMemoryLeaks(saver, file: file, line: line)
        return (sut, saver)
    }
}
