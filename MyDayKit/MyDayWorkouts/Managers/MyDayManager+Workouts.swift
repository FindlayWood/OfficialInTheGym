//
//  MyDayManager+Workouts.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/06/2026.
//

import Foundation

extension MyDayManager {

    /// Add a workout template to today's day model.
    public func addWorkoutToDay(_ template: WorkoutTemplateModel) {
        guard var day = selectedDay else { return }
        let entry = DailyWorkoutEntry(
            template: template,
            assignedDate: day.date
        )
        day.workouts.append(entry)
        selectedDay = day
        Task {
            try await workoutSaver.save(data: day)
        }
    }

    /// Remove a workout entry from the selected day and persist.
    ///
    /// **A completed workout cannot be removed.** It is a record of work that was
    /// actually performed — it has raw logs behind it, it counts toward stats, and
    /// once assignment ships a coach may have been told about it. `DailyWorkoutCard`
    /// hides the options menu for a completed entry; this guard is what makes it an
    /// invariant rather than a convention the next caller can breach.
    public func removeWorkoutFromDay(_ entry: DailyWorkoutEntry) {
        guard entry.status != .completed else { return }
        guard var day = selectedDay else { return }
        day.workouts.removeAll { $0.id == entry.id }
        selectedDay = day
        deleteWorkoutStats(for: entry)
        deleteCompletedSession(for: entry)
        Task {
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
