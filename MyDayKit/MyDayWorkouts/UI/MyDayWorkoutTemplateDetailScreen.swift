//
//  MyDayWorkoutTemplateDetailScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct MyDayWorkoutTemplateDetailScreen: View {

    let template: WorkoutTemplateModel

    var onAddToTodayTapped: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            metricsStrip

            Divider()

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(template.exercises) { exercise in
                        MyDayExerciseTemplateCard(exercise: exercise)
                    }
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.darkColor)
        }
        .navigationTitle(template.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            addToTodayButton
        }
    }

    // MARK: - Metrics Strip

    private var metricsStrip: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("EXERCISES")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                Text("\(template.exercises.count)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.primary)
            }

            if let duration = template.estimatedDuration {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DURATION")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .tracking(1.2)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text("\(duration)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.primary)
                        Text("min")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }

            Spacer()

            if let difficulty = template.difficulty {
                Text(difficulty.rawValue.capitalized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(difficultyColor(difficulty))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(difficultyColor(difficulty).opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Add to Today Button

    private var addToTodayButton: some View {
        Button {
            onAddToTodayTapped?()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Add to Today")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.darkColor)
                    .shadow(color: Color.darkColor.opacity(0.35), radius: 12, x: 0, y: 6)
            )
            .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Helpers

    private func difficultyColor(_ difficulty: WorkoutDifficulty) -> Color {
        switch difficulty {
        case .beginner:     return .green
        case .intermediate: return .orange
        case .advanced:     return .red
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyDayWorkoutTemplateDetailScreen(
            template: WorkoutTemplateModel(
                id: "1",
                title: "Monday Upper",
                description: nil,
                exercises: [
                    WorkoutExerciseModel(
                        id: "e1",
                        exerciseId: "Bench Press",
                        orderIndex: 0,
                        sets: [
                            WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
                            WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
                            WorkoutSetModel(id: "s3", orderIndex: 2, reps: 6, weight: 85, weightUnit: .kg)
                        ],
                        notes: "Keep elbows at 45 degrees"
                    ),
                    WorkoutExerciseModel(
                        id: "e2",
                        exerciseId: "Pull Ups",
                        orderIndex: 1,
                        sets: [
                            WorkoutSetModel(id: "s4", orderIndex: 0, reps: 10),
                            WorkoutSetModel(id: "s5", orderIndex: 1, reps: 10)
                        ]
                    ),
                    WorkoutExerciseModel(
                        id: "e3",
                        exerciseId: "Dumbbell Curl",
                        orderIndex: 2,
                        sets: [
                            WorkoutSetModel(id: "s6", orderIndex: 0, reps: 12, weight: 15, weightUnit: .kg, eachSide: true),
                            WorkoutSetModel(id: "s7", orderIndex: 1, reps: 12, weight: 15, weightUnit: .kg, eachSide: true)
                        ]
                    )
                ],
                createdBy: "user1",
                isPublic: false,
                tags: nil,
                estimatedDuration: 60,
                difficulty: .intermediate,
                createdAt: .now,
                updatedAt: .now
            )
        )
    }
}
