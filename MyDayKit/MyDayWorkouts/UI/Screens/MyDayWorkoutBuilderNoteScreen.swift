//
//  MyDayWorkoutBuilderNoteScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/06/2026.
//

import SwiftUI

struct MyDayWorkoutBuilderNoteScreen: View {

    @ObservedObject var exercise: WorkoutExerciseBuilderManager
    @State private var noteText: String = ""
    @State private var selectedSetIndices: Set<Int> = []
    @FocusState private var isFocused: Bool

    var continueAction: (() -> Void)?

    // MARK: - Computed helpers

    private var allSetsMode: Bool { selectedSetIndices.isEmpty }
    private var isValid: Bool { !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var characterCount: Int { noteText.count }
    private let characterLimit = 300

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
                            .background(allSetsMode ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    ForEach(exercise.sets.indices, id: \.self) { index in
                        let set = exercise.sets[index]
                        let isSelected = selectedSetIndices.contains(index)
                        let hasNote = set.note != nil

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

                                if hasNote {
                                    Image(systemName: "note.text")
                                        .font(.system(size: 10, weight: .regular))
                                        .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                                }
                            }
                            .frame(width: 72, height: 52)
                            .background(isSelected ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        hasNote && !isSelected ? Color.darkColor.opacity(0.4) : Color.clear,
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
                    .foregroundStyle(Color.darkColor)

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
                .padding(.bottom, 16)

            // ── Text editor ────────────────────────────────────────────
            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {

                    if noteText.isEmpty {
                        Text("e.g. Felt strong, kept back straight...")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }

                    TextEditor(text: $noteText)
                        .font(.system(size: 15, weight: .regular))
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(minHeight: 120, maxHeight: 200)
                        .onChange(of: noteText) { _, newValue in
                            if newValue.count > characterLimit {
                                noteText = String(newValue.prefix(characterLimit))
                            }
                        }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isFocused ? Color.darkColor.opacity(0.5) : Color(UIColor.separator),
                            lineWidth: isFocused ? 1.5 : 0.5
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }

                Text("\(characterCount)/\(characterLimit)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(
                        characterCount > Int(Double(characterLimit) * 0.9)
                            ? Color.orange
                            : Color(UIColor.tertiaryLabel)
                    )
            }
            .padding(.horizontal, 16)

            // ── Quick suggestions ──────────────────────────────────────
            if noteText.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Suggestions")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button {
                                    noteText = suggestion
                                    isFocused = true
                                } label: {
                                    Text(suggestion)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .clipShape(Capsule())
                                        .overlay {
                                            Capsule()
                                                .stroke(Color(UIColor.separator), lineWidth: 0.5)
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()

            // ── Done button ────────────────────────────────────────────
            Button {
                doneAction()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isValid ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle("Note")
        .onAppear {
            loadInputForSelection()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }

    // MARK: - Suggestions

    private var suggestions: [String] {
        [
            "Felt strong 💪",
            "Form needs work",
            "Increase weight next time",
            "Reduce weight next time",
            "Paused at bottom",
            "Slow eccentric",
            "PR attempt",
            "Fatigued",
        ]
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

        let notes = targets.compactMap(\.note)

        // Only pre-fill when all targets share the same note
        if notes.count == targets.count,
           let first = notes.first, notes.allSatisfy({ $0 == first }) {
            noteText = first
        } else {
            noteText = ""
        }
    }

    private func applyToTargets() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let targets = allSetsMode
            ? Array(exercise.sets.indices)
            : selectedSetIndices.sorted()

        for index in targets {
            exercise.sets[index].setNote(trimmed)
        }
        exercise.objectWillChange.send()
    }

    private func doneAction() {
        applyToTargets()
        continueAction?()
    }
}

// MARK: - Preview

#Preview {
    let exercise = WorkoutExerciseBuilderManager(exercise: .pressUps)
    exercise.addSets(4)
    return MyDayWorkoutBuilderNoteScreen(exercise: exercise)
}
