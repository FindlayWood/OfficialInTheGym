//
//  MyDayFullDayModel+Schedules.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

extension MyDayFullDayModel {

    /// The workouts due on this day and not yet on it, as cards to draw. **These are built for
    /// display and are not saved**: a plan must not count towards anything until the user acts on it,
    /// and stats, streaks and markers read only what is saved.
    ///
    /// **Left out when:**
    /// - the day already holds an entry from that schedule, started or not;
    /// - the user said "Not today";
    /// - the day already holds that workout, added by hand, since two identical cards would leave
    ///   the user guessing which to open;
    /// - the template cannot be found, since a card with nothing to open is worse than none.
    ///
    /// **The entry id is derived from the schedule and the day**, so the card keeps its identity
    /// across renders and once it is saved, and two devices acting on it write the same entry.
    func dueWorkouts(
        schedules: [Schedule],
        templates: [WorkoutTemplateModel],
        calendar: Calendar = .current
    ) -> [DailyWorkoutEntry] {
        let scheduleDay = ScheduleDay(date, calendar: calendar)
        let usedSchedules = Set(workouts.compactMap(\.scheduleId))
        let usedTemplates = Set(workouts.map(\.template.id))
        let skipped = Set(skippedSchedules ?? [])

        return schedules.compactMap { schedule in
            guard
                schedule.isDue(on: scheduleDay),
                !usedSchedules.contains(schedule.id),
                !skipped.contains(schedule.id),
                case .workout(let templateId) = schedule.item,
                !usedTemplates.contains(templateId),
                let template = templates.first(where: { $0.id == templateId })
            else {
                return nil
            }
            return DailyWorkoutEntry(
                id: "\(schedule.id)-\(scheduleDay.key)",
                template: template,
                assignedDate: date,
                scheduleId: schedule.id
            )
        }
    }

    /// The sports due on this day and not logged yet, as cards to draw. Not saved, as `dueWorkouts`
    /// is not.
    ///
    /// **Left out when** the day already holds a session from that schedule, the user said "Not today",
    /// or that sport was logged by hand today, game or training. A session logged the normal way is
    /// the session the schedule meant, and a card still asking for it would read as unfinished.
    ///
    /// Removing a logged session takes it off the day, so its card comes back. Unlike a workout, there
    /// is nothing to start: someone removing a session most likely logged it by mistake.
    func dueSports(schedules: [Schedule], calendar: Calendar = .current) -> [ScheduledSport] {
        let scheduleDay = ScheduleDay(date, calendar: calendar)
        let logged = sports ?? []
        let usedSchedules = Set(logged.compactMap(\.scheduleId))
        let usedSports = Set(logged.map(\.sport))
        let skipped = Set(skippedSchedules ?? [])

        return schedules.compactMap { schedule in
            guard
                schedule.isDue(on: scheduleDay),
                !usedSchedules.contains(schedule.id),
                !skipped.contains(schedule.id),
                case .sport(let sport, let duration) = schedule.item,
                !usedSports.contains(sport)
            else {
                return nil
            }
            return ScheduledSport(scheduleId: schedule.id, day: scheduleDay, sport: sport, duration: duration)
        }
    }

    /// The day with `entry` saved on it. Unchanged if it is already there, so a second tap cannot add
    /// it twice or put a planned copy over a session in progress.
    func addingScheduledWorkout(_ entry: DailyWorkoutEntry) -> MyDayFullDayModel {
        guard !workouts.contains(where: { $0.id == entry.id }) else { return self }
        var day = self
        day.workouts.append(entry)
        return day
    }

    /// The day with `scheduleId` marked "Not today". **Kept on the day rather than on the device**, so
    /// the card stays gone on every device the user opens.
    func skippingSchedule(_ scheduleId: String) -> MyDayFullDayModel {
        var day = self
        var skipped = day.skippedSchedules ?? []
        if !skipped.contains(scheduleId) {
            skipped.append(scheduleId)
        }
        day.skippedSchedules = skipped
        return day
    }
}
