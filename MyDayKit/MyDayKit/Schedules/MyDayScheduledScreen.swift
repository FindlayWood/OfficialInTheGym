//
//  MyDayScheduledScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import SwiftUI

/// Everything the user has scheduled, soonest first. A row opens `ScheduleSheet` to change or stop it.
///
/// Schedules are also listed where they are set, on the workout page and the sport screen. This is
/// the one place that shows them all, and the only way to reach a schedule without knowing which page
/// set it.
struct MyDayScheduledScreen: View {

    @ObservedObject var manager: ScheduleManager
    @ObservedObject var libraryManager: WorkoutLibraryManager

    @State private var editing: ScheduledListRow?

    private var today: ScheduleDay {
        ScheduleDay(Date())
    }

    private var templates: [WorkoutTemplateModel] {
        guard case .loaded(let templates) = libraryManager.state else { return [] }
        return templates
    }

    private var rows: [ScheduledListRow] {
        ScheduledListRow.rows(schedules: manager.schedules, templates: templates, today: today)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                if rows.isEmpty {
                    emptyCard
                } else {
                    ForEach(rows) { row in
                        rowCard(for: row)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Scheduled")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await manager.loadIfNeeded()
            libraryManager.loadIfNeeded()
        }
        .sheet(item: $editing) { row in
            ScheduleSheet(
                model: ScheduleFormModel(
                    title: row.title,
                    item: row.schedule.item,
                    editing: row.schedule,
                    manager: manager
                )
            )
        }
    }

    // MARK: - Rows

    private func rowCard(for row: ScheduledListRow) -> some View {
        Button {
            editing = row
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.darkColor)
                        .frame(width: 44, height: 44)
                    Image(systemName: row.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(row.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                    Text(row.schedule.summary)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                    Text("Next: \(row.nextDay.displayText(relativeTo: today))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.darkColor)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty

    /// Says where schedules are made, since this screen does not make them: a schedule starts from
    /// the workout or sport it is for.
    private var emptyCard: some View {
        VStack(spacing: 6) {
            Text("Nothing scheduled")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)
            Text("Open a workout or a sport's training session and tap Schedule. It will be waiting on MyDay when the day comes.")
                .font(.system(size: 13))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
