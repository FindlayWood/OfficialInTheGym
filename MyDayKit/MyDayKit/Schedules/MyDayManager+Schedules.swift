//
//  MyDayManager+Schedules.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

extension MyDayManager {

    /// Saves a due workout onto today, with the template as it is now, when the user opens its card.
    /// From here it is an ordinary entry: same session, same logs, and later edits to the template
    /// change only future days.
    ///
    /// **Today only.** The phone's day-file saver names its file by today's date, so saving any other
    /// day would overwrite today's file. Due cards are only drawn on today, and this guard is what
    /// makes that an invariant.
    public func addScheduledWorkout(_ entry: DailyWorkoutEntry) {
        guard isTodaySelected(), let day = selectedDay else { return }
        let updated = day.addingScheduledWorkout(entry)
        selectedDay = updated
        Task { [workoutSaver] in
            try await workoutSaver.save(data: updated)
        }
    }
}
