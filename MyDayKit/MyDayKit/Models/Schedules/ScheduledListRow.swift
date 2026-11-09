//
//  ScheduledListRow.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// One line on `MyDayScheduledScreen`.
struct ScheduledListRow: Identifiable, Equatable {
    let schedule: Schedule
    let title: String
    let icon: String
    let nextDay: ScheduleDay

    var id: String { schedule.id }

    /// Every schedule still to come, **soonest first**, since "what is next" is what the list is for.
    /// Stopped schedules and finished one-offs are left out.
    ///
    /// A workout is named from the library. **One not found still gets a row**, called "Workout":
    /// it may only mean the library has not loaded yet, and this is the one place the user could
    /// stop it.
    static func rows(
        schedules: [Schedule],
        templates: [WorkoutTemplateModel],
        today: ScheduleDay
    ) -> [ScheduledListRow] {
        schedules
            .compactMap { schedule -> ScheduledListRow? in
                guard let nextDay = schedule.nextDue(onOrAfter: today) else { return nil }

                switch schedule.item {
                case .workout(let templateId):
                    return ScheduledListRow(
                        schedule: schedule,
                        title: templates.first { $0.id == templateId }?.title ?? "Workout",
                        icon: "dumbbell.fill",
                        nextDay: nextDay
                    )
                case .sport(let sport, _):
                    return ScheduledListRow(
                        schedule: schedule,
                        title: sport.rawValue,
                        icon: sport.icon,
                        nextDay: nextDay
                    )
                }
            }
            .sorted { first, second in
                first.nextDay == second.nextDay ? first.title < second.title : first.nextDay < second.nextDay
            }
    }
}
