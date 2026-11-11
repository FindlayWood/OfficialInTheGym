//
//  ReminderPlanner.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Turns the user's preferences and what today already holds into the notifications that
/// should be pending. **The only reminder logic there is** — the scheduler only makes the
/// pending set match what this returns.
///
/// **One-off requests for each day, never a repeating trigger.** A local notification cannot
/// look at anything when it fires, so "skip it once I've checked in" can only be done by
/// removing that day's request beforehand. A repeating trigger has no day to remove. So the
/// planner names each day separately, `horizonDays` ahead, and every save, every return to the
/// app and every settings change plans again. Someone who stays away longer than the horizon
/// stops being reminded, which is the right failure: two weeks of nudges about an app they have
/// stopped opening is enough.
///
/// **Rating is today only, and only once training is recorded.** MyDay's rating step does not
/// open until something is (`MyDayDayMarkers.hasExercise`), so a reminder on a day with nothing
/// logged would ask for something the screen refuses. Future days cannot be known yet; logging
/// on one of them is a save, and that save plans the reminder.
///
/// iOS keeps at most 64 pending requests per app. Fourteen check-ins and one rating leave room
/// for the trial reminder and for schedule and injury reminders still to come.
enum ReminderPlanner {

    static let horizonDays = 14

    static func plan(
        preferences: ReminderPreferences,
        today: MyDayDayMarkers,
        now: Date,
        calendar: Calendar = .current
    ) -> [PlannedReminder] {
        let todayKey = ScheduleDay(now, calendar: calendar)
        var planned: [PlannedReminder] = []

        for offset in 0..<horizonDays {
            let day = todayKey.adding(days: offset)
            guard preferences.checkIn.applies(on: day) else { continue }
            if offset == 0 && today.hasCheckIn { continue }
            let fireDate = preferences.checkIn.time.date(on: day, calendar: calendar)
            guard fireDate > now else { continue }
            planned.append(PlannedReminder(
                kind: .checkIn,
                day: day,
                fireDate: fireDate,
                title: "Morning check-in",
                body: "How did you sleep, and how does your body feel? It takes ten seconds."
            ))
        }

        if preferences.dayRating.applies(on: todayKey), today.hasExercise, !today.hasRPE {
            let fireDate = preferences.dayRating.time.date(on: todayKey, calendar: calendar)
            if fireDate > now {
                planned.append(PlannedReminder(
                    kind: .dayRating,
                    day: todayKey,
                    fireDate: fireDate,
                    title: "Rate your day",
                    body: "You trained today. How hard did it feel?"
                ))
            }
        }

        return planned.sorted { $0.fireDate < $1.fireDate }
    }
}
