//
//  MyDayWorkoutSessionExerciseCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct MyDayWorkoutSessionExerciseCard: View {

    let exercise: WorkoutExerciseModel
    let setRecords: [WorkoutSetRecord]
    let isSessionStarted: Bool
    var onCompleteSet: ((WorkoutSetModel, Int) -> Void)?
    var onExerciseTapped: (() -> Void)?
    var onRPETapped: (() -> Void)?
    var onCameraTapped: (() -> Void)?

    private var completedRepsText: String {
        let reps = setRecords.filter(\.isCompleted).compactMap(\.reps)
        guard !reps.isEmpty else { return "" }
        return reps.map { "\($0)" }.joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if !exercise.sets.isEmpty {
                Divider()
                    .padding(.horizontal, 16)
                setsRow
            }

            Divider()
                .padding(.horizontal, 16)
            actionsRow
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

                if !completedRepsText.isEmpty {
                    Text(completedRepsText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .animation(.easeInOut(duration: 0.2), value: completedRepsText)
                }
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
                    let record = setRecords.first(where: { $0.id == set.id })
                    SessionSetPill(
                        index: index,
                        set: set,
                        isLogged: record?.isCompleted ?? false,
                        isDisabled: !isSessionStarted,
                        onTap: { onCompleteSet?(set, index) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Actions Row

    private var actionsRow: some View {
        HStack(spacing: 0) {
            Button {
                onRPETapped?()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gauge.medium")
                        .font(.system(size: 14, weight: .medium))
                    Text("RPE")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 18)

            Button {
                onCameraTapped?()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14, weight: .medium))
                    Text("Clip")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview

#Preview {
    let exercise = WorkoutExerciseModel(
        id: "e1",
        exerciseId: "Bench Press",
        orderIndex: 0,
        sets: [
            WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
            WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
            WorkoutSetModel(id: "s3", orderIndex: 2, reps: 6, weight: 85, weightUnit: .kg)
        ],
        restSeconds: 90
    )

    let allRecords: [WorkoutSetRecord] = [
        WorkoutSetRecord(id: "s1", isCompleted: true, reps: 8, weight: 80, weightUnit: .kg, completedAt: .now),
        WorkoutSetRecord(id: "s2", isCompleted: true, reps: 8, weight: 80, weightUnit: .kg, completedAt: .now),
        WorkoutSetRecord(id: "s3", isCompleted: true, reps: 6, weight: 85, weightUnit: .kg, completedAt: .now)
    ]

    ScrollView {
        VStack(spacing: 16) {
            MyDayWorkoutSessionExerciseCard(
                exercise: exercise,
                setRecords: [
                    WorkoutSetRecord(id: "s1", isCompleted: false),
                    WorkoutSetRecord(id: "s2", isCompleted: false),
                    WorkoutSetRecord(id: "s3", isCompleted: false)
                ],
                isSessionStarted: false
            )

            MyDayWorkoutSessionExerciseCard(
                exercise: exercise,
                setRecords: [
                    WorkoutSetRecord(id: "s1", isCompleted: true, reps: 8, weight: 80, weightUnit: .kg),
                    WorkoutSetRecord(id: "s2", isCompleted: false),
                    WorkoutSetRecord(id: "s3", isCompleted: false)
                ],
                isSessionStarted: true
            )

            MyDayWorkoutSessionExerciseCard(
                exercise: exercise,
                setRecords: allRecords,
                isSessionStarted: true
            )
        }
        .padding(16)
    }
    .background(Color(UIColor.systemGroupedBackground))
}
