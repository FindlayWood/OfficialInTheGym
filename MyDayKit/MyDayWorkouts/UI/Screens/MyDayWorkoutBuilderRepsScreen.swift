//
//  MyDayWorkoutBuilderRepsScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/05/2026.
//

import SwiftUI

struct MyDayWorkoutBuilderRepsScreen: View {

    @ObservedObject var exercise: WorkoutExerciseBuilderManager
    @State var reps: Int = 0
    @State private var stringInput: String = ""
    @State private var selectedSetIndices: Set<Int> = []

    var add: (() -> ())?

    private var hasInput: Bool { !stringInput.isEmpty }
    private var allSetsMode: Bool { selectedSetIndices.isEmpty }
    private var allSetsHaveReps: Bool {
        exercise.sets.allSatisfy { $0.reps != nil }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Set selector ───────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "All sets" pill
                    Button {
                        selectedSetIndices.removeAll()
                        loadInputForSelection()
                    } label: {
                        Text("All sets")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(allSetsMode ? Color.white : Color.secondary)
                            .frame(width: 72, height: 52)
                            .background(allSetsMode ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    // Individual set pills
                    ForEach(exercise.sets.indices, id: \.self) { index in
                        let set = exercise.sets[index]
                        let isSelected = selectedSetIndices.contains(index)
                        let hasReps = set.reps != nil

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

                                if let reps = set.reps {
                                    Text("\(reps)")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                                }
                            }
                            .frame(width: 72, height: 52)
                            .background(isSelected ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(hasReps && !isSelected ? Color.darkColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 4)
            }
            .padding(.bottom, 12)
            


            // ── Applying to label ──────────────────────────────────────
            HStack {
                Image(systemName: allSetsMode ? "square.stack.3d.up" : "checkmark.circle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.darkColor)

                Text(applyingToLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondary)

                Spacer()
            }
            .frame(height: 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            .animation(.easeInOut(duration: 0.2), value: selectedSetIndices)

            Spacer()

            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 8) {
                Text(exercise.exercise.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(hasInput ? "\(reps)" : "–")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(hasInput ? Color.primary : Color(UIColor.tertiaryLabel))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.15), value: reps)

                    if hasInput {
                        Text(reps == 1 ? "rep" : "reps")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .padding(.bottom, 8)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.15), value: hasInput)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()
                .padding(.bottom, 8)

            // ── Number pad ─────────────────────────────────────────────
            CustomNumberPad(
                backspaceDisabled: stringInput.isEmpty,
                zeroDisabled: stringInput.isEmpty,
                selection: { number in
                    stringInput.append("\(number)")
                    reps = Int(stringInput) ?? 1
                    applyRepsToTargets()
                },
                backspace: {
                    stringInput.removeLast()
                    reps = Int(stringInput) ?? 1
                    applyRepsToTargets()
                }
            )
            
            Spacer()
            
            // ── Continue ───────────────────────────────────────────
            Button {
                add?()
            } label: {
                Text("Continue")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(allSetsHaveReps ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(allSetsHaveReps ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!allSetsHaveReps)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

        }
        .navigationTitle("Reps")
    }

    // ── Helpers ────────────────────────────────────────────────────────

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

    /// When the selection changes, pre-fill the input if all selected sets share the same rep count.
    private func loadInputForSelection() {
        let targets: [WorkoutExerciseSetManager]
        if allSetsMode {
            targets = exercise.sets
        } else {
            targets = selectedSetIndices.sorted().map { exercise.sets[$0] }
        }

        let repValues = targets.compactMap(\.reps)
        if repValues.count == targets.count, let first = repValues.first, repValues.allSatisfy({ $0 == first }) {
            // All targets have the same value — pre-fill
            stringInput = "\(first)"
            reps = first
        } else {
            stringInput = ""
            reps = 0
        }
    }

    private func applyRepsToTargets() {
        let targets = allSetsMode
            ? exercise.sets.indices.map { $0 }
            : selectedSetIndices.sorted()

        for index in targets {
            exercise.sets[index].setReps(reps)
        }
    }
}

#Preview {
    MyDayWorkoutBuilderRepsScreen(exercise: WorkoutExerciseBuilderManager(exercise: .pressUps))
}
