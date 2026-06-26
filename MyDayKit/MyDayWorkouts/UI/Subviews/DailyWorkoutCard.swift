//
//  DailyWorkoutCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/06/2026.
//

import SwiftUI

struct DailyWorkoutCard: View {

    let entry: DailyWorkoutEntry
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: 0) {

                // MARK: - Header
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(statusColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: statusIcon)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(statusColor)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(entry.template.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Text(subtitleText)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    statusBadge
                }
                .padding(16)

                // MARK: - Progress bar (inProgress only)
                if case .inProgress = entry.status {
                    Divider()
                        .padding(.horizontal, 16)

                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange)
                        Text("In progress — tap to continue")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                // MARK: - Incomplete notice
                if case .incomplete = entry.status {
                    Divider()
                        .padding(.horizontal, 16)

                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text("Not completed")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.borderless)
    }

    // MARK: - Helpers

    private var subtitleText: String {
        let count = entry.template.exercises.count
        let exercises = "\(count) \(count == 1 ? "exercise" : "exercises")"
        let creator = entry.template.createdBy
        return "\(exercises) · \(creator)"
    }

    private var statusColor: Color {
        switch entry.status {
        case .planned:    return Color.darkColor
        case .inProgress: return .orange
        case .completed:  return .green
        case .incomplete: return Color(.systemGray)
        }
    }

    private var statusIcon: String {
        switch entry.status {
        case .planned:    return "figure.strengthtraining.traditional"
        case .inProgress: return "bolt.fill"
        case .completed:  return "checkmark.seal.fill"
        case .incomplete: return "xmark.circle.fill"
        }
    }

    private var statusBadge: some View {
        Group {
            switch entry.status {
            case .planned:
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.darkColor)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.darkColor.opacity(0.1))
                    )
            case .inProgress:
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                    )
            case .completed:
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.1))
                    )
            case .incomplete:
                EmptyView()
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: WorkoutTemplateModel(id: "1", title: "Monday Upper", description: nil, exercises: [], createdBy: "findlay", isPublic: false, tags: nil, estimatedDuration: 60, difficulty: .intermediate, createdAt: .now, updatedAt: .now),
            assignedDate: .now,
            status: .planned
        ))
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: WorkoutTemplateModel(id: "2", title: "Tuesday Lower", description: nil, exercises: [], createdBy: "findlay", isPublic: false, tags: nil, estimatedDuration: 45, difficulty: .intermediate, createdAt: .now, updatedAt: .now),
            assignedDate: .now,
            status: .inProgress
        ))
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: WorkoutTemplateModel(id: "3", title: "Thursday Push", description: nil, exercises: [], createdBy: "findlay", isPublic: false, tags: nil, estimatedDuration: 50, difficulty: .advanced, createdAt: .now, updatedAt: .now),
            assignedDate: .now,
            status: .completed
        ))
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: WorkoutTemplateModel(id: "4", title: "Friday Pull", description: nil, exercises: [], createdBy: "findlay", isPublic: false, tags: nil, estimatedDuration: nil, difficulty: nil, createdAt: .now, updatedAt: .now),
            assignedDate: .now,
            status: .incomplete
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
