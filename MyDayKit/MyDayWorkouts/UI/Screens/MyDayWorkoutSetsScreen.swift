//
//  MyDayWorkoutSetsScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/05/2026.
//

import SwiftUI

struct MyDayWorkoutSetsScreen: View {

    @ObservedObject var manager: WorkoutExerciseBuilderManager
    @State var sets: Int = 0
    @State private var stringInput: String = ""

    var add: (() -> ())?

    private var hasInput: Bool { !stringInput.isEmpty }

    var body: some View {
        VStack(spacing: 0) {

            // ── Sets display ───────────────────────────────────────────
            VStack(spacing: 8) {
                Text(manager.exercise.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(hasInput ? "\(sets)" : "–")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(hasInput ? Color.primary : Color(UIColor.tertiaryLabel))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.15), value: sets)

                    if hasInput {
                        Text(sets == 1 ? "set" : "sets")
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
            .padding(.bottom, 20)

            Divider()
                .padding(.bottom, 8)

            // ── Number pad ─────────────────────────────────────────────
            CustomNumberPad(
                backspaceDisabled: stringInput.isEmpty,
                zeroDisabled: stringInput.isEmpty,
                selection: { number in
                    stringInput.append("\(number)")
                    sets = Int(stringInput) ?? 1
                },
                backspace: {
                    stringInput.removeLast()
                    sets = Int(stringInput) ?? 1
                }
            )

            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction()
            } label: {
                Text(hasInput ? "Add \(sets) \(sets == 1 ? "set" : "sets")" : "Enter sets")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(hasInput ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(hasInput ? Color.blue : Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: hasInput)
            }
            .disabled(!hasInput)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .navigationTitle("Sets")
    }

    func addAction() {
        manager.addSets(sets)
        add?()
    }
}

#Preview {
    MyDayWorkoutSetsScreen(
        manager: WorkoutExerciseBuilderManager(exercise: .pressUps)
    )
}
