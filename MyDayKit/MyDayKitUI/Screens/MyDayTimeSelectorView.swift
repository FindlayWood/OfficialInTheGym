//
//  MyDayTimeSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 30/10/2025.
//

import SwiftUI

struct MyDayTimeSelectorView: View {
    
    @State private var value: Int
    
    private var isValidSelection: Bool { value > 0 }
    
    let steps: [Int] = [1, 5, 10, 30, 60, 300]
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    let newExercise: MyDayNewExerciseManager
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._value = State(initialValue: newExercise.time ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Time")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("Tap the steps to adjust")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // ── Live time display ──────────────────────────────────────
            VStack(spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    timeComponent(value: value / 60, unit: "m")
                    timeComponent(value: value % 60, unit: "s")
                }
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: value)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
            
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
                                color: Color.red,
                                disabled: value == 0
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    value = max(0, value - step)
                                }
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
                            .foregroundStyle(Color.darkColor.opacity(0.7))
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
                                color: Color.darkColor,
                                disabled: false
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    value = min(999_999, value + step)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction()
            } label: {
                Text(isValidSelection ? "Add \(displayTime(for: value))" : "Select a time")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValidSelection ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isValidSelection
                            ? Color.darkColor
                            : Color(UIColor.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValidSelection)
            }
            .disabled(!isValidSelection)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
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
    
    func formattedStep(_ step: Int) -> String {
        step >= 60 ? "\(step / 60)m" : "\(step)s"
    }
    
    func displayTime(for totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func addAction() {
        newExercise.setTime(value)
        continueAction?()
    }
}


#Preview {
    MyDayTimeSelectorView(newExercise: .init(exercise: .pressUps))
}
