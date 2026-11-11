//
//  ReminderManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Keeps the pending reminders in step with the user's settings and with today.
///
/// It plans again whenever something that changes the answer happens — the app becoming active
/// (`refresh`), today's day being saved (`dayChanged`), or the settings changing (`update`) —
/// and hands the result to the scheduler. There is no other trigger and no timer: a check-in
/// saved at 07:55 is a `dayChanged`, and that removes the 08:00 reminder before it fires.
///
/// **Replacements run one after another.** Each is a remove followed by an add; two running at
/// once can interleave so that the older plan's requests land after the newer plan's removal,
/// bringing back a reminder that had just been cancelled. `scheduling` chains every replace on
/// the one before it.
///
/// Built once per signed-in session in `MyDayKitComposition`; signing out calls `stop()`.
@MainActor
public final class ReminderManager {

    // MARK: - Dependencies
    private let store: ReminderPreferencesStore
    private let scheduler: ReminderScheduling
    private let permission: ReminderPermissionAsking
    private let todayLoader: MyDayLoader
    private let now: () -> Date
    private let calendar: Calendar

    // MARK: - Properties
    public private(set) var preferences: ReminderPreferences
    /// The last thing known about today, so a settings change plans without reading the day
    /// again. Dropped once its day has passed.
    private var today: (day: ScheduleDay, markers: MyDayDayMarkers)?
    private(set) var scheduling: Task<Void, Never>?

    // MARK: - Init
    /// `nonisolated` so the composition can build it while composing the tab, which is not
    /// itself on the main actor. It only stores what it is given.
    nonisolated public init(
        store: ReminderPreferencesStore,
        scheduler: ReminderScheduling,
        permission: ReminderPermissionAsking,
        todayLoader: MyDayLoader,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.store = store
        self.scheduler = scheduler
        self.permission = permission
        self.todayLoader = todayLoader
        self.now = now
        self.calendar = calendar
        self.preferences = store.load()
    }
}

// MARK: - Planning
extension ReminderManager {

    /// Reads today afresh and plans. For launch and every return to the app — the day may have
    /// rolled over, or been logged on another device, while the app was away.
    public func refresh() async {
        let date = now()
        let day: MyDayFullDayModel? = try? await todayLoader.load(for: date)
        record(markers: day.map(MyDayDayMarkers.init(day:)) ?? .none, on: ScheduleDay(date, calendar: calendar))
        replan()
    }

    /// Today's day was saved. Any other day is ignored: a past day cannot change what is still
    /// to fire.
    public func dayChanged(_ day: MyDayFullDayModel) {
        let key = ScheduleDay(day.date, calendar: calendar)
        guard key == ScheduleDay(now(), calendar: calendar) else { return }
        let markers = MyDayDayMarkers(day: day)
        if let today, today.day == key, today.markers == markers { return }
        record(markers: markers, on: key)
        replan()
    }

    /// Saves the new settings and plans with them at once — the user is looking at the switch
    /// they just turned on.
    public func update(_ preferences: ReminderPreferences) {
        guard preferences != self.preferences else { return }
        self.preferences = preferences
        store.save(preferences)
        replan()
    }

    /// Removes every reminder. For signing out: the next person to use the phone must not be
    /// nudged about someone else's check-in.
    public func stop() async {
        today = nil
        schedule([])
        await scheduling?.value
    }

    private func record(markers: MyDayDayMarkers, on day: ScheduleDay) {
        today = (day, markers)
    }

    private func replan() {
        let date = now()
        let key = ScheduleDay(date, calendar: calendar)
        let markers = (today?.day == key ? today?.markers : nil) ?? .none
        let plan = ReminderPlanner.plan(preferences: preferences, today: markers, now: date, calendar: calendar)
        schedule(plan)
    }

    private func schedule(_ plan: [PlannedReminder]) {
        let previous = scheduling
        let scheduler = scheduler
        scheduling = Task {
            await previous?.value
            await scheduler.replaceReminders(with: plan)
        }
    }
}

// MARK: - Permission
extension ReminderManager {

    public func permissionStatus() async -> ReminderPermissionStatus {
        await permission.status()
    }

    public func requestPermission() async -> Bool {
        await permission.request()
    }
}
