//
//  MyDayManager+Workouts.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/06/2026.
//

import Foundation

extension MyDayManager {

    /// Add a workout template to **today**, whatever day MyDay has open.
    ///
    /// This used to be `addWorkoutToDay`, which appended to `selectedDay`. Inside MyDay that was
    /// safe only by accident: past days are read-only and hide Add. Once the workout page is
    /// reachable from another tab (PROFILE, `PROFILE_WORKOUTS_PLAN.md`), MyDay can be sitting on
    /// any day. The workout would land on that day, and because `MyDayFileManagerSaver` names its
    /// file by **today's** date, saving it would overwrite today's file with the past day's
    /// content. **"Add to Today" means today, so it never reads `selectedDay` unless that is
    /// today.**
    public func addWorkoutToToday(_ template: WorkoutTemplateModel) {
        Task { await addingWorkoutToToday(template) }
    }

    /// The work behind `addWorkoutToToday`, awaitable so a test can see it finish.
    ///
    /// When today is open, it is the freshest copy there is and is used as is. Otherwise today is
    /// loaded; **a load that fails saves nothing**, since an empty day written over a real one
    /// would lose everything logged on it. A day with no document yet is a new, empty day, as
    /// `initialLoad` treats one. Today is checked again after the load, because MyDay may have
    /// switched to today while it ran, and then `selectedDay` holds anything logged meanwhile.
    @MainActor
    func addingWorkoutToToday(_ template: WorkoutTemplateModel) async {
        var loadedToday: MyDayFullDayModel?
        if !isTodaySelected() {
            do {
                loadedToday = try await loader.load(for: .now)
            } catch {
                print("❌ Couldn't load today to add a workout: \(error)")
                return
            }
        }

        let todayIsOpen = isTodaySelected()
        guard var day = todayIsOpen
            ? selectedDay
            : loadedToday ?? MyDayFullDayModel(id: UUID().uuidString, date: .now, exercises: [], workouts: [])
        else { return }

        day.workouts.append(DailyWorkoutEntry(template: template, assignedDate: day.date))

        if todayIsOpen {
            selectedDay = day
        } else {
            // What `selectedDay`'s `didSet` would have done: today's strip marker and the reminder
            // planner both have to see the change, though another day is on screen.
            recordMarkers(for: day)
            onDayChanged?(day)
        }

        do {
            try await workoutSaver.save(data: day)
        } catch {
            print("❌ Couldn't save today's workout: \(error)")
        }
    }

    /// Remove a workout entry from the selected day and persist.
    ///
    /// **A completed workout cannot be removed.** It is a record of work that was
    /// actually performed — it has raw logs behind it, it counts toward stats, and
    /// once assignment ships a coach may have been told about it. `DailyWorkoutCard`
    /// hides the options menu for a completed entry; this guard is what makes it an
    /// invariant rather than a convention the next caller can breach.
    ///
    /// **A scheduled workout is also marked skipped**, whether or not it was saved yet: a due card has
    /// no entry to remove, and one that was saved would otherwise come straight back as a due card.
    public func removeWorkoutFromDay(_ entry: DailyWorkoutEntry) {
        guard entry.status != .completed else { return }
        guard var day = selectedDay else { return }
        day.workouts.removeAll { $0.id == entry.id }
        if let scheduleId = entry.scheduleId {
            day = day.skippingSchedule(scheduleId)
        }
        selectedDay = day
        deleteWorkoutStats(for: entry)
        deleteCompletedSession(for: entry)
        Task { [workoutSaver, day] in
            try await workoutSaver.save(data: day)
        }
    }

    /// Update an existing workout entry — called when session status changes
    /// (e.g. planned → inProgress → completed).
    public func updateWorkoutEntry(_ entry: DailyWorkoutEntry) {
        guard var day = selectedDay else { return }
        guard let index = day.workouts.firstIndex(where: { $0.id == entry.id }) else { return }
        day.workouts[index] = entry
        selectedDay = day
        Task {
            try await workoutSaver.save(data: day)
        }
    }
}
