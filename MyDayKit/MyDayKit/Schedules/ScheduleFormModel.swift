//
//  ScheduleFormModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Combine
import Foundation

/// The state behind `ScheduleSheet`, for a new schedule or an existing one.
///
/// **`recurrence` is the one gate.** It is `nil` until the answers make a schedule, and the sheet
/// draws Save and the "Next" line from it, so what the sheet says is what will be saved.
///
/// **Every two weeks asks which week, not which date.** The weekdays cannot say which Tuesdays are
/// meant, and only the week holding `start` decides that, so "this week or next" is the whole
/// question. A date picker would offer dozens of answers that mean one of those two.
///
/// **Weekdays start unpicked**, rather than on today's weekday. A preselected day would count as
/// chosen when the user never chose it, and a card would appear on it.
///
/// Built by the coordinators, which are not main-actor isolated, so the methods that publish are
/// marked rather than the whole class.
final class ScheduleFormModel: ObservableObject {

    enum Frequency: CaseIterable {
        case weekly, everyTwoWeeks
    }

    enum FirstWeek: CaseIterable {
        case this, next
    }

    @Published var repeats: Bool
    @Published var date: Date
    @Published var frequency: Frequency
    @Published var weekdays: Set<ScheduleWeekday>
    @Published var firstWeek: FirstWeek

    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?

    let title: String
    let isEditing: Bool

    private let item: ScheduleItem
    private let editing: Schedule?
    private let manager: ScheduleManager
    private let now: () -> Date
    private let calendar: Calendar

    // MARK: - Init

    init(
        title: String,
        item: ScheduleItem,
        editing: Schedule? = nil,
        manager: ScheduleManager,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.title = title
        self.item = editing?.item ?? item
        self.editing = editing
        self.isEditing = editing != nil
        self.manager = manager
        self.now = now
        self.calendar = calendar

        let today = ScheduleDay(now(), calendar: calendar)
        let tomorrow = today.adding(days: 1).date(calendar: calendar)

        switch editing?.recurrence {
        case .once(let day):
            repeats = false
            date = day.date(calendar: calendar)
            frequency = .weekly
            weekdays = []
            firstWeek = .this
        case .weekly(let days, _):
            repeats = true
            date = tomorrow
            frequency = .weekly
            weekdays = days
            firstWeek = .this
        case .everyTwoWeeks(let days, let start):
            repeats = true
            date = tomorrow
            frequency = .everyTwoWeeks
            weekdays = days
            // The same weeks as before, read from today. Saving rebuilds `start` from this answer.
            firstWeek = today.weeks(sinceWeekOf: start) % 2 == 0 ? .this : .next
        case nil:
            repeats = false
            date = tomorrow
            frequency = .weekly
            weekdays = []
            firstWeek = .this
        }
    }

    // MARK: - Answers

    /// `nil` until a repeat has at least one weekday.
    var recurrence: ScheduleRecurrence? {
        guard repeats else {
            return .once(day: ScheduleDay(date, calendar: calendar))
        }
        guard !weekdays.isEmpty else { return nil }

        switch frequency {
        case .weekly:
            return .weekly(weekdays: weekdays, start: today)
        case .everyTwoWeeks:
            return .everyTwoWeeks(weekdays: weekdays, start: firstWeekStart)
        }
    }

    /// "Next: Tue 10 Nov", or what is still missing. Only says a date `recurrence` itself produced.
    var nextText: String {
        guard let recurrence else { return "Pick at least one day" }
        guard let next = recurrence.nextOccurrence(onOrAfter: today) else { return "This date has passed" }
        return "Next: \(next.displayText(relativeTo: today))"
    }

    var canSave: Bool {
        !isSaving && recurrence?.nextOccurrence(onOrAfter: today) != nil
    }

    /// The first date a one-off can be set for.
    var earliestDate: Date {
        today.date(calendar: calendar)
    }

    private var today: ScheduleDay {
        ScheduleDay(now(), calendar: calendar)
    }

    /// Today, or the Monday of next week. Which day of the week it is makes no difference to which
    /// weeks are on, only to which days of the first week can still fall.
    private var firstWeekStart: ScheduleDay {
        switch firstWeek {
        case .this: return today
        case .next: return today.adding(days: 7 - today.weekday.rawValue)
        }
    }

    // MARK: - Editing

    func toggle(_ weekday: ScheduleWeekday) {
        if weekdays.contains(weekday) {
            weekdays.remove(weekday)
        } else {
            weekdays.insert(weekday)
        }
    }

    // MARK: - Saving

    /// `true` once saved, for the sheet to close. A failure stays on the sheet with the answers
    /// intact, since they are what the user needs to try again.
    @MainActor
    func save() async -> Bool {
        guard canSave, let recurrence else { return false }
        return await perform { [self] in
            try await manager.save(schedule(with: recurrence))
        }
    }

    /// Stops the schedule being edited.
    @MainActor
    func stop() async -> Bool {
        guard let editing else { return false }
        return await perform { [self] in
            try await manager.stop(editing)
        }
    }

    @MainActor
    private func perform(_ write: () async throws -> Void) async -> Bool {
        isSaving = true
        saveError = nil
        defer { isSaving = false }

        do {
            try await write()
            return true
        } catch {
            saveError = "Couldn't save that. Please try again."
            return false
        }
    }

    private func schedule(with recurrence: ScheduleRecurrence) -> Schedule {
        if var edited = editing {
            edited.recurrence = recurrence
            return edited
        }
        return Schedule(
            id: UUID().uuidString,
            item: item,
            recurrence: recurrence,
            createdAt: now(),
            updatedAt: now()
        )
    }
}
