//
//  MyDayExerciseTemplateCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct MyDayExerciseTemplateCard: View {

    let exercise: WorkoutExerciseModel
    var onExerciseTapped: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            header

            if !exercise.sets.isEmpty {
                Divider()
                    .padding(.horizontal, 16)
                setsRow
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Button {
                    onExerciseTapped?()
                } label: {
                    Text(exercise.exerciseId)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Sets Row

    private var setsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    MyDayTemplateSetPill(index: index, set: set)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            MyDayExerciseTemplateCard(
                exercise: WorkoutExerciseModel(
                    id: "e1",
                    exerciseId: "Bench Press",
                    orderIndex: 0,
                    sets: [
                        WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
                        WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
                        WorkoutSetModel(id: "s3", orderIndex: 2, reps: 6, weight: 85, weightUnit: .kg)
                    ],
                    restSeconds: 90,
                    notes: "Keep elbows at 45 degrees"
                )
            )
            MyDayExerciseTemplateCard(
                exercise: WorkoutExerciseModel(
                    id: "e2",
                    exerciseId: "Pull Ups",
                    orderIndex: 1,
                    sets: [
                        WorkoutSetModel(id: "s4", orderIndex: 0, reps: 10),
                        WorkoutSetModel(id: "s5", orderIndex: 1, reps: 10)
                    ]
                )
            )
            MyDayExerciseTemplateCard(
                exercise: WorkoutExerciseModel(
                    id: "e3",
                    exerciseId: "Plank",
                    orderIndex: 2,
                    sets: [
                        WorkoutSetModel(id: "s6", orderIndex: 0, time: 60),
                        WorkoutSetModel(id: "s7", orderIndex: 1, time: 45)
                    ]
                )
            )
        }
        .padding(16)
    }
    .background(Color.darkColor)
}
