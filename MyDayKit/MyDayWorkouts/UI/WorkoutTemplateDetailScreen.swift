//
//  WorkoutTemplateDetailScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/06/2026.
//

import SwiftUI

struct WorkoutTemplateDetailScreen: View {

    let template: WorkoutTemplateModel

    var onStartTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: - Metadata Card
                metadataCard

                // MARK: - Exercises Label
                HStack {
                    Text("Exercises")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(1.2)
                    Spacer()
                    Text("\(template.exercises.count) \(template.exercises.count == 1 ? "exercise" : "exercises")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                // MARK: - Exercise Cards
                ForEach(template.exercises) { exercise in
                    ExerciseTemplateCard(exercise: exercise)
                        .padding(.horizontal, 20)
                }

                Color.clear.frame(height: 100)
            }
            .padding(.top, 16)
        }
        .navigationTitle(template.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onEditTapped?()
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            startButton
        }
    }

    // MARK: - Metadata Card

    private var metadataCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {

                if let difficulty = template.difficulty {
                    metadataChip(
                        icon: "chart.bar.fill",
                        label: difficulty.rawValue.capitalized,
                        color: difficultyColor(difficulty)
                    )
                }

                if let duration = template.estimatedDuration {
                    metadataChip(
                        icon: "clock.fill",
                        label: "\(duration) min",
                        color: .blue
                    )
                }

                metadataChip(
                    icon: "dumbbell.fill",
                    label: "\(template.exercises.count) exercises",
                    color: Color.darkColor
                )

                Spacer()
            }

            if let description = template.description {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let tags = template.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.darkColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.darkColor.opacity(0.1))
                                )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 20)
    }

    private func metadataChip(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(label)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }

    private func difficultyColor(_ difficulty: WorkoutDifficulty) -> Color {
        switch difficulty {
        case .beginner:     return .green
        case .intermediate: return .orange
        case .advanced:     return .red
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            onStartTapped?()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Start Workout")
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
        .padding(.bottom, 24)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Exercise Template Card

private struct ExerciseTemplateCard: View {

    let exercise: WorkoutExerciseModel
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.accentColor)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.exerciseId)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("\(exercise.sets.count) \(exercise.sets.count == 1 ? "set" : "sets")")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
            }
            .buttonStyle(.borderless)

            // MARK: Expanded Sets
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                if exercise.sets.isEmpty {
                    HStack {
                        Text("No sets configured")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                                SetTemplateView(index: index, set: set)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }

                if let notes = exercise.notes {
                    Divider()
                        .padding(.horizontal, 16)

                    HStack(spacing: 6) {
                        Image(systemName: "note.text")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(notes)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Set Template View

private struct SetTemplateView: View {

    let index: Int
    let set: WorkoutSetModel

    var body: some View {
        VStack(spacing: 6) {
            Text("Set \(index + 1)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            VStack(spacing: 3) {
                if let reps = set.reps {
                    Text("\(reps)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("reps")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                if let weight = set.weight {
                    Text(formattedWeight(weight, unit: set.weightUnit))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.darkColor)
                }

                if let time = set.time {
                    Text(formattedTime(time))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("time")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                if let distance = set.distance {
                    Text(formattedDistance(distance, unit: set.distanceUnit))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.darkColor)
                }
            }

            if set.eachSide == true {
                Text("each side")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.darkColor.opacity(0.7)))
            }
        }
        .frame(width: 72, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func formattedWeight(_ weight: Double, unit: WeightUnit?) -> String {
        let unitLabel = unit?.rawValue ?? "kg"
        return weight.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(weight))\(unitLabel)"
            : "\(weight)\(unitLabel)"
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }

    private func formattedDistance(_ distance: Double, unit: DistanceUnit?) -> String {
        let unitLabel = unit?.rawValue ?? "m"
        return distance.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(distance))\(unitLabel)"
            : "\(distance)\(unitLabel)"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WorkoutTemplateDetailScreen(
            template: WorkoutTemplateModel(
                id: "1",
                title: "Monday Upper",
                description: "Focus on pushing and pulling movements with moderate volume.",
                exercises: [
                    WorkoutExerciseModel(
                        id: "e1",
                        exerciseId: "Bench Press",
                        orderIndex: 0,
                        sets: [
                            WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
                            WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
                            WorkoutSetModel(id: "s3", orderIndex: 2, reps: 6, weight: 85, weightUnit: .kg),
                        ],
                        notes: "Keep elbows at 45 degrees"
                    ),
                    WorkoutExerciseModel(
                        id: "e2",
                        exerciseId: "Pull Ups",
                        orderIndex: 1,
                        sets: [
                            WorkoutSetModel(id: "s4", orderIndex: 0, reps: 10, eachSide: false),
                            WorkoutSetModel(id: "s5", orderIndex: 1, reps: 10, eachSide: false),
                        ]
                    ),
                    WorkoutExerciseModel(
                        id: "e3",
                        exerciseId: "Dumbbell Curl",
                        orderIndex: 2,
                        sets: [
                            WorkoutSetModel(id: "s6", orderIndex: 0, reps: 12, weight: 15, weightUnit: .kg, eachSide: true),
                            WorkoutSetModel(id: "s7", orderIndex: 1, reps: 12, weight: 15, weightUnit: .kg, eachSide: true),
                        ]
                    )
                ],
                createdBy: "user1",
                isPublic: false,
                tags: ["Upper", "Strength", "Hypertrophy"],
                estimatedDuration: 60,
                difficulty: .intermediate,
                createdAt: .now,
                updatedAt: .now
            )
        )
    }
}
