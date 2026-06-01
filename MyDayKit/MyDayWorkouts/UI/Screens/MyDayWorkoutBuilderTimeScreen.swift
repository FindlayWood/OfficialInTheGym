//
//  MyDayWorkoutBuilderTimeScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/06/2026.
//

import SwiftUI

struct MyDayWorkoutBuilderTimeScreen: View {

    @ObservedObject var exercise: WorkoutExerciseBuilderManager
    @State private var value: Int = 0
    @State private var selectedSetIndices: Set<Int> = []

    var continueAction: (() -> Void)?

    // MARK: - Computed helpers

    private var allSetsMode: Bool { selectedSetIndices.isEmpty }
    private var isValidSelection: Bool { value > 0 }

    let steps: [Int] = [1, 5, 10, 30, 60, 300]
    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {

            // ── Set selector ───────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {

                    Button {
                        selectedSetIndices.removeAll()
                        loadInputForSelection()
                    } label: {
                        Text("All sets")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(allSetsMode ? Color.white : Color.secondary)
                            .frame(width: 72, height: 52)
                            .background(allSetsMode ? Color.blue : Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    ForEach(exercise.sets.indices, id: \.self) { index in
                        let set = exercise.sets[index]
                        let isSelected = selectedSetIndices.contains(index)
                        let hasTime = set.time != nil

                        Button {
                            if isSelected {
                                selectedSetIndices.remove(index)
                            } else {
                                selectedSetIndices.insert(index)
                            }
                            loadInputForSelection()
                        } label: {
                            VStack(spacing: 2) {
                                Text("Set \(index + 1)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(isSelected ? Color.white : Color.primary)

                                if let time = set.time {
                                    Text(displayTime(for: time))
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                            }
                            .frame(width: 72, height: 52)
                            .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        hasTime && !isSelected ? Color.blue.opacity(0.4) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .padding(.vertical, 12)

            // ── Applying-to label ──────────────────────────────────────
            HStack {
                Image(systemName: allSetsMode ? "square.stack.3d.up" : "checkmark.circle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.blue)

                Text(applyingToLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondary)

                Spacer()
            }
            .frame(height: 20)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .animation(.easeInOut(duration: 0.2), value: selectedSetIndices)

            Divider()

            // ── Live time display ──────────────────────────────────────
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                timeComponent(value: value / 60, unit: "m")
                timeComponent(value: value % 60, unit: "s")
            }
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.15), value: value)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            // ── Step buttons ───────────────────────────────────────────
            VStack(spacing: 12) {

                // Subtract row
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.red.opacity(0.7))
                        Text("Remove")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Spacer()
                    }

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(steps, id: \.self) { step in
                            stepButton(
                                label: formattedStep(step),
                                prefix: "−",
                                color: .red,
                                disabled: value == 0
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    value = max(0, value - step)
                                }
                                applyToTargets()
                            }
                        }
                    }
                }

                Divider()

                // Add row
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.blue.opacity(0.7))
                        Text("Add")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Spacer()
                    }

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(steps, id: \.self) { step in
                            stepButton(
                                label: formattedStep(step),
                                prefix: "+",
                                color: .blue,
                                disabled: false
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    value = min(999_999, value + step)
                                }
                                applyToTargets()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            // ── Done button ────────────────────────────────────────────
            Button {
                doneAction()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValidSelection ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isValidSelection ? Color.blue : Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValidSelection)
            }
            .disabled(!isValidSelection)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle("Time")
    }

    // MARK: - Time Component

    @ViewBuilder
    private func timeComponent(value: Int, unit: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text("\(value)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    value > 0
                        ? Color.primary
                        : Color(UIColor.tertiaryLabel)
                )
                .monospacedDigit()
            Text(unit)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .padding(.bottom, 6)
        }
    }

    // MARK: - Step Button

    @ViewBuilder
    private func stepButton(
        label: String,
        prefix: String,
        color: Color,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(prefix)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(disabled ? Color(UIColor.tertiaryLabel) : color)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(disabled ? Color(UIColor.tertiaryLabel) : Color.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                disabled
                    ? Color(UIColor.tertiarySystemBackground)
                    : color.opacity(0.08)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(disabled)
    }

    // MARK: - Helpers

    private var applyingToLabel: String {
        if allSetsMode {
            return "Applying to all \(exercise.sets.count) sets"
        } else if selectedSetIndices.count == 1 {
            return "Applying to Set \(selectedSetIndices.first! + 1)"
        } else {
            let names = selectedSetIndices.sorted().map { "Set \($0 + 1)" }.joined(separator: ", ")
            return "Applying to \(names)"
        }
    }

    private func loadInputForSelection() {
        let targets: [WorkoutExerciseSetManager] = allSetsMode
            ? exercise.sets
            : selectedSetIndices.sorted().map { exercise.sets[$0] }

        let values = targets.compactMap(\.time)

        // Only pre-fill when all targets share the same value
        if values.count == targets.count,
           let firstValue = values.first, values.allSatisfy({ $0 == firstValue }) {
            value = firstValue
        } else {
            value = 0
        }
    }

    private func applyToTargets() {
        guard value > 0 else { return }

        let targets = allSetsMode
            ? Array(exercise.sets.indices)
            : selectedSetIndices.sorted()

        for index in targets {
            exercise.sets[index].setTime(value)
        }
        exercise.objectWillChange.send()
    }

    private func doneAction() {
        continueAction?()
    }

    private func formattedStep(_ step: Int) -> String {
        step >= 60 ? "\(step / 60)m" : "\(step)s"
    }

    private func displayTime(for totalSeconds: Int) -> String {
        String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

// MARK: - Preview

#Preview {
    let exercise = WorkoutExerciseBuilderManager(exercise: .pressUps)
    exercise.addSets(4)
    return MyDayWorkoutBuilderTimeScreen(exercise: exercise)
}
