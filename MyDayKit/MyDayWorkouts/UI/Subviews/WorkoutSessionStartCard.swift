//
//  WorkoutSessionStartCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/06/2026.
//

import SwiftUI

struct WorkoutSessionStartCard: View {

    let entry: DailyWorkoutEntry
    var onStart: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(UIColor.tertiaryLabel))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            VStack(spacing: 6) {
                Text(entry.template.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                Text(subtitleText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            Button {
                onStart?()
            } label: {
                Text("Start Workout")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.darkColor)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: -4)
    }

    private var subtitleText: String {
        let count = entry.template.exercises.count
        let exercises = "\(count) \(count == 1 ? "exercise" : "exercises")"
        if let duration = entry.template.estimatedDuration {
            return "\(exercises) · \(duration) min"
        }
        return exercises
    }
}

// MARK: - Preview

#Preview {
    ZStack(alignment: .bottom) {
        Color(UIColor.systemGroupedBackground).ignoresSafeArea()
        WorkoutSessionStartCard(
            entry: DailyWorkoutEntry(
                template: WorkoutTemplateModel(
                    id: "1",
                    title: "Monday Upper",
                    description: nil,
                    exercises: [
                        WorkoutExerciseModel(id: "e1", exerciseId: "Bench Press", orderIndex: 0, sets: [
                            WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg)
                        ]),
                        WorkoutExerciseModel(id: "e2", exerciseId: "Pull Ups", orderIndex: 1, sets: [
                            WorkoutSetModel(id: "s2", orderIndex: 0, reps: 10)
                        ])
                    ],
                    createdBy: "user1",
                    isPublic: false,
                    tags: nil,
                    estimatedDuration: 60,
                    difficulty: .intermediate,
                    createdAt: .now,
                    updatedAt: .now
                ),
                assignedDate: .now
            )
        )
    }
}
