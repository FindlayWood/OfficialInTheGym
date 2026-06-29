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
        ZStack(alignment: .topTrailing) {
            // Full-card tap navigates to session
            cardContent

            // Ellipsis sits above the card button in the ZStack so it wins its hit area
            Button { showOptions = true } label: {
                ZStack {
                    Circle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 32, height: 32)
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(width: 50, height: 50)
            }
            .buttonStyle(.plain)
            .padding(8)
        }
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

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {

            // MARK: - Top row: type label
            Text("WORKOUT")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.5)

            // MARK: - Title
            Text(entry.template.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)

            // MARK: - Subtitle + status chip
            HStack {
                Text(subtitleText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
                statusChip
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onStart?()
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
