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
