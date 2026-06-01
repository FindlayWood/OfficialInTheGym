//
//  MyDayWorkoutBuilderTempoScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/06/2026.
//

import SwiftUI

struct MyDayWorkoutBuilderTempoScreen: View {

    @ObservedObject var exercise: WorkoutExerciseBuilderManager
    @State private var tempo: Tempo = .init()
    @State private var selectedSetIndices: Set<Int> = []

    var continueAction: (() -> Void)?

    // MARK: - Computed helpers

    private var allSetsMode: Bool { selectedSetIndices.isEmpty }

    private var isValidSelection: Bool {
        tempo.eccentric > 0 || tempo.eccentricHold > 0 ||
        tempo.concentric > 0 || tempo.concentricHold > 0
    }

    private var tempoString: String {
        "\(tempo.eccentric)–\(tempo.eccentricHold)–\(tempo.concentric)–\(tempo.concentricHold)"
    }

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
                        let hasTempo = set.tempo != nil

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

                                if let t = set.tempo {
                                    Text("\(t.eccentric)–\(t.eccentricHold)–\(t.concentric)–\(t.concentricHold)")
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
                                        hasTempo && !isSelected ? Color.blue.opacity(0.4) : Color.clear,
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

            // ── Live tempo preview ─────────────────────────────────────
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(tempoString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(isValidSelection ? Color.primary : Color(UIColor.tertiaryLabel))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: tempo.eccentric)
                    .animation(.easeInOut(duration: 0.15), value: tempo.eccentricHold)
                    .animation(.easeInOut(duration: 0.15), value: tempo.concentric)
                    .animation(.easeInOut(duration: 0.15), value: tempo.concentricHold)

                Text("sec")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.secondary)
                    .padding(.bottom, 4)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            // ── Tempo columns ──────────────────────────────────────────
            HStack(spacing: 10) {
                tempoColumn(label: "Down",  sublabel: "Eccentric",  value: $tempo.eccentric)
                tempoColumn(label: "Hold",  sublabel: "Bottom",     value: $tempo.eccentricHold)
                tempoColumn(label: "Up",    sublabel: "Concentric", value: $tempo.concentric)
                tempoColumn(label: "Hold",  sublabel: "Top",        value: $tempo.concentricHold)
            }
            .padding(.horizontal, 16)
            .onChange(of: tempo) { _,_ in
                applyToTargets()
            }

            // ── Info hint ──────────────────────────────────────────────
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary)
                Text("Each number is the seconds spent in that phase.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

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
        .navigationTitle("Tempo")
    }

    // MARK: - Tempo Column

    @ViewBuilder
    private func tempoColumn(label: String, sublabel: String, value: Binding<Int>) -> some View {
        VStack(spacing: 10) {

            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(sublabel)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }

            Button {
                value.wrappedValue += 1
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.blue)
                }
            }

            Text("\(value.wrappedValue)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(value.wrappedValue > 0 ? Color.primary : Color(UIColor.tertiaryLabel))
                .frame(height: 36)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: value.wrappedValue)

            Button {
                value.wrappedValue = max(0, value.wrappedValue - 1)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(value.wrappedValue > 0 ? Color.red.opacity(0.1) : Color(UIColor.tertiarySystemBackground))
                        .frame(height: 44)
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(value.wrappedValue > 0 ? Color.red : Color(UIColor.tertiaryLabel))
                }
            }
            .disabled(value.wrappedValue == 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
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

        let values = targets.compactMap(\.tempo)

        // Only pre-fill when all targets share the same tempo
        if values.count == targets.count,
           let first = values.first,
           values.allSatisfy({
               $0.eccentric == first.eccentric &&
               $0.eccentricHold == first.eccentricHold &&
               $0.concentric == first.concentric &&
               $0.concentricHold == first.concentricHold
           }) {
            tempo = first
        } else {
            tempo = .init()
        }
    }

    private func applyToTargets() {
        guard isValidSelection else { return }

        let targets = allSetsMode
            ? Array(exercise.sets.indices)
            : selectedSetIndices.sorted()

        for index in targets {
            exercise.sets[index].setTempo(tempo)
        }
        exercise.objectWillChange.send()
    }

    private func doneAction() {
        continueAction?()
    }
}

// MARK: - Preview

#Preview {
    let exercise = WorkoutExerciseBuilderManager(exercise: .squat)
    exercise.addSets(4)
    return MyDayWorkoutBuilderTempoScreen(exercise: exercise)
}
