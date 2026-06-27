//
//  DailyWorkoutCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/06/2026.
//

import SwiftUI

struct DailyWorkoutCard: View {

    let entry: DailyWorkoutEntry
    var onStart: (() -> Void)?
    var onDelete: (() -> Void)?

    @State private var showOptions = false

    var body: some View {
        Button {
            showOptions = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {

                // MARK: - Top row: type label + status chip
                HStack {
                    Text("WORKOUT")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(1.5)
                    Spacer()
                    statusChip
                }

                // MARK: - Title + ellipsis
                HStack(alignment: .center) {
                    Text(entry.template.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }

                // MARK: - Subtitle
                Text(subtitleText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.borderless)
        .sheet(isPresented: $showOptions) {
            WorkoutCardOptionsSheet(
                entry: entry,
                onStart: {
                    showOptions = false
                    onStart?()
                },
                onDelete: {
                    showOptions = false
                    onDelete?()
                }
            )
            .presentationDetents([.height(210)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Status Chip

    @ViewBuilder
    private var statusChip: some View {
        switch entry.status {
        case .planned:
            EmptyView()
        case .inProgress:
            HStack(spacing: 5) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 6, height: 6)
                Text("In Progress")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.orange)
            }
        case .completed:
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.green)
                Text("Completed")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.green)
            }
        case .incomplete:
            Text("Incomplete")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Subtitle

    private var subtitleText: String {
        let count = entry.template.exercises.count
        let exercises = "\(count) \(count == 1 ? "exercise" : "exercises")"

        if let startedAt = entry.startedAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "\(exercises) · Started \(formatter.string(from: startedAt))"
        }

        if let duration = entry.template.estimatedDuration {
            return "\(exercises) · \(duration) min"
        }

        return exercises
    }
}

#Preview {
    let template: (String, String, Int?, WorkoutDifficulty?) -> WorkoutTemplateModel = { id, title, duration, difficulty in
        WorkoutTemplateModel(id: id, title: title, description: nil, exercises: [
            WorkoutExerciseModel(id: "e1", exerciseId: "Bench Press", orderIndex: 0, sets: [
                WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg)
            ]),
            WorkoutExerciseModel(id: "e2", exerciseId: "Pull Ups", orderIndex: 1, sets: [
                WorkoutSetModel(id: "s2", orderIndex: 0, reps: 10)
            ]),
            WorkoutExerciseModel(id: "e3", exerciseId: "Dumbbell Curl", orderIndex: 2, sets: [
                WorkoutSetModel(id: "s3", orderIndex: 0, reps: 12, weight: 15, weightUnit: .kg)
            ])
        ], createdBy: "findlay", isPublic: false, tags: nil, estimatedDuration: duration, difficulty: difficulty, createdAt: .now, updatedAt: .now)
    }

    VStack(spacing: 12) {
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: template("1", "Monday Upper", 60, .intermediate),
            assignedDate: .now,
            status: .planned
        ))
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: template("2", "Tuesday Lower", 45, .intermediate),
            assignedDate: .now,
            status: .inProgress,
            startedAt: Calendar.current.date(byAdding: .minute, value: -18, to: .now)
        ))
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: template("3", "Thursday Push", 50, .advanced),
            assignedDate: .now,
            status: .completed,
            startedAt: Calendar.current.date(byAdding: .hour, value: -1, to: .now)
        ))
        DailyWorkoutCard(entry: DailyWorkoutEntry(
            template: template("4", "Friday Pull", nil, nil),
            assignedDate: .now,
            status: .incomplete
        ))
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
