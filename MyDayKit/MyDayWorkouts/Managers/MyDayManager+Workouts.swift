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
    public func removeWorkoutFromDay(_ entry: DailyWorkoutEntry) {
        guard var day = selectedDay else { return }
        day.workouts.removeAll { $0.id == entry.id }
        selectedDay = day
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
