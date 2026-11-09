//
//  WorkoutScheduleRows.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import SwiftUI

/// When this workout is scheduled, on its detail page. Draws nothing until there is a schedule, and
/// a row opens it again to change or stop.
///
/// It is the confirmation that Save worked, and the way to undo it, in the place the user set it.
struct WorkoutScheduleRows: View {

    @ObservedObject var manager: ScheduleManager
    let templateId: String
    let onSelect: (Schedule) -> Void

    private var today: ScheduleDay {
        ScheduleDay(Date())
    }

    private var schedules: [Schedule] {
        manager.active(on: today).filter { $0.item == .workout(templateId: templateId) }
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(schedules) { schedule in
                Divider()
                row(for: schedule)
            }
        }
        .task {
            await manager.loadIfNeeded()
        }
    }

    private func row(for schedule: Schedule) -> some View {
        Button {
            onSelect(schedule)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(schedule.recurrence.summary)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    if let next = schedule.nextDue(onOrAfter: today) {
                        Text("Next: \(next.displayText(relativeTo: today))")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
