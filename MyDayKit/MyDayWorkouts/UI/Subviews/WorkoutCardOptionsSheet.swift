//
//  WorkoutCardOptionsSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct WorkoutCardOptionsSheet: View {

    let entry: DailyWorkoutEntry
    var onStart: (() -> Void)?
    var onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    /// A scheduled workout not started yet is put off rather than removed: it comes back on its next
    /// day. Once started, this also discards what was logged, so it says "Remove" as any workout does.
    private var isPutOff: Bool {
        entry.scheduleId != nil && entry.status == .planned
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.template.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            Divider()

            Button {
                onStart?()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.darkColor)
                        .frame(width: 28)
                    Text("Start Workout")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.leading, 62)

            Button {
                onDelete?()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: isPutOff ? "calendar.badge.minus" : "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 28)
                    Text(isPutOff ? "Not Today" : "Remove from Today")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }
}

#Preview {
    WorkoutCardOptionsSheet(
        entry: DailyWorkoutEntry(
            template: WorkoutTemplateModel(
                id: "1",
                title: "Monday Upper",
                description: nil,
                exercises: [],
                createdBy: "user",
                isPublic: false,
                tags: nil,
                estimatedDuration: 60,
                difficulty: .intermediate,
                createdAt: .now,
                updatedAt: .now
            ),
            assignedDate: .now,
            status: .planned
        )
    )
    .presentationDetents([.height(210)])
}
