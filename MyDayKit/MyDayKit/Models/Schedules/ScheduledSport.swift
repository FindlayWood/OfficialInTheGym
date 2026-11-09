//
//  ScheduledSport.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// A sport due on a day and not logged yet, as `ScheduledSportCard` draws it. **Not saved**, for the
/// same reason a due workout is not: a plan counts towards nothing until the user presses Done.
struct ScheduledSport: Identifiable, Equatable {
    let scheduleId: String
    let day: ScheduleDay
    let sport: SportType
    /// Seconds. Only fills in the card, which the user can change for today.
    let duration: Int

    var id: String { scheduleId }

    /// What Done records, the same session the normal sport flow writes.
    ///
    /// **The id is derived from the schedule and the day**, so a second press, or a press on another
    /// device, corrects the one session rather than adding a second to the day and to stats.
    func makeEntry(duration: Int, rpe: Int, performedAt: Date) -> SportSessionEntry {
        SportSessionEntry(
            id: "\(scheduleId)-\(day.key)",
            sport: sport,
            sessionType: .training,
            performedAt: performedAt,
            duration: duration,
            playingTime: nil,
            rpe: rpe,
            result: nil,
            teamScore: nil,
            opponentScore: nil,
            note: nil,
            scheduleId: scheduleId
        )
    }
}
