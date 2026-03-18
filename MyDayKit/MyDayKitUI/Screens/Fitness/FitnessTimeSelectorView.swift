//
//  FitnessTimeSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/03/2026.
//

import SwiftUI

// MARK: - FitnessTimeSelectorView

struct FitnessTimeSelectorView: View {
    
    @ObservedObject var manager: MyDayNewFitnessManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var value: Int
    
    private var isValid: Bool { value > 0 }
    
    let steps: [Int] = [1, 5, 10, 30, 60, 300]
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    init(manager: MyDayNewFitnessManager) {
        self.manager = manager
        self._value = State(initialValue: manager.duration)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Duration")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("How long was your session?")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // ── Live time display ──────────────────────────────────────
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                timeComponent(value: value / 3600, unit: "h")
                timeComponent(value: (value % 3600) / 60, unit: "m")
                timeComponent(value: value % 60, unit: "s")
            }
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.15), value: value)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
            
            // ── Step buttons ───────────────────────────────────────────
            VStack(spacing: 12) {
                stepSection(
                    label: "Remove",
                    icon: "minus.circle.fill",
                    color: .red,
                    disabled: value == 0
                ) { step in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        value = max(0, value - step)
                    }
                }
                
                Divider()
                
                stepSection(
                    label: "Add",
                    icon: "plus.circle.fill",
                    color: manager.activity.color,
                    disabled: false
                ) { step in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        value = min(86400, value + step) // max 24 hours
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            // ── Save button ────────────────────────────────────────────
            Button {
                manager.duration = value
                dismiss()
            } label: {
                Text(isValid ? "Set \(formattedDuration(value))" : "Select a duration")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isValid
                            ? manager.activity.color
                            : Color(UIColor.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(manager.activity.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Step Section
    
    @ViewBuilder
    private func stepSection(
        label: String,
        icon: String,
        color: Color,
        disabled: Bool,
        onStep: @escaping (Int) -> Void
    ) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color.opacity(0.7))
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(steps, id: \.self) { step in
                    stepButton(
                        label: formattedStep(step),
                        color: color,
                        disabled: disabled
                    ) {
                        onStep(step)
                    }
                }
            }
        }
    }
    
    // MARK: - Step Button
    
    @ViewBuilder
    private func stepButton(
        label: String,
        color: Color,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(disabled ? Color(UIColor.tertiaryLabel) : Color.primary)
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
    
    // MARK: - Time Component
    
    @ViewBuilder
    private func timeComponent(value: Int, unit: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text("\(value)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(
                    value > 0
                        ? Color.primary
                        : Color(UIColor.tertiaryLabel)
                )
                .monospacedDigit()
            Text(unit)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .padding(.bottom, 4)
        }
    }
    
    // MARK: - Helpers
    
    private func formattedStep(_ step: Int) -> String {
        if step >= 3600 { return "\(step / 3600)h" }
        if step >= 60   { return "\(step / 60)m" }
        return "\(step)s"
    }
    
    private func formattedDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        
        if h > 0 {
            return s == 0 ? "\(h)h \(m)m" : "\(h)h \(m)m \(s)s"
        } else if m > 0 {
            return s == 0 ? "\(m)m" : "\(m)m \(s)s"
        } else {
            return "\(s)s"
        }
    }
}

// MARK: - FitnessDistanceSelectorView

struct FitnessDistanceSelectorView: View {
    
    @ObservedObject var manager: MyDayNewFitnessManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedUnit: DistanceUnit?
    @State private var value: Double
    @State private var stringInput: String = ""
    
    private var isValid: Bool {
        guard selectedUnit != nil else { return false }
        return value > 0
    }
    
    private var displayValue: String {
        stringInput.isEmpty ? "0" : stringInput
    }
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    init(manager: MyDayNewFitnessManager) {
        self.manager = manager
        self._selectedUnit = State(initialValue: manager.distanceUnits)
        self._value = State(initialValue: manager.distance ?? 0)
        if let existing = manager.distance, existing > 0 {
            self._stringInput = State(
                initialValue: existing.formatted(.number.precision(.fractionLength(0...2)))
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Distance")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("How far did you go?")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // ── Live value display ─────────────────────────────────────
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(displayValue)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        isValid
                            ? Color.primary
                            : Color(UIColor.tertiaryLabel)
                    )
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: stringInput)
                
                if let unit = selectedUnit {
                    Text(unit.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .padding(.bottom, 6)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .animation(.easeInOut(duration: 0.2), value: selectedUnit)
            
            // ── Unit selector ──────────────────────────────────────────
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                    unitButton(unit)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            // ── Number pad ─────────────────────────────────────────────
            if selectedUnit != nil {
                Divider()
                    .padding(.bottom, 8)
                
                CustomNumberPad(
                    showingDecimalPoint: true,
                    decimalDisabled: decimalDisabled,
                    backspaceDisabled: stringInput.isEmpty,
                    zeroDisabled: stringInput.isEmpty,
                    decimalSelected: {
                        stringInput.append(".")
                        value = Double(stringInput) ?? 0
                    },
                    selection: { number in
                        stringInput.append("\(number)")
                        value = Double(stringInput) ?? 0
                    },
                    backspace: {
                        stringInput.removeLast()
                        value = Double(stringInput) ?? 0
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.2), value: selectedUnit)
            }
            
            Spacer()
            
            // ── Save button ────────────────────────────────────────────
            Button {
                manager.distance = value
                manager.distanceUnits = selectedUnit
                dismiss()
            } label: {
                Group {
                    if isValid, let unit = selectedUnit {
                        Text("Set \(stringInput) \(unit.rawValue)")
                    } else if selectedUnit != nil {
                        Text("Enter a distance")
                    } else {
                        Text("Select a unit")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isValid ? Color.white : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    isValid
                        ? manager.activity.color
                        : Color(UIColor.secondarySystemBackground)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(manager.activity.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Unit Button
    
    @ViewBuilder
    private func unitButton(_ unit: DistanceUnit) -> some View {
        let isSelected = selectedUnit == unit
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedUnit = unit == selectedUnit ? nil : unit
                value = 0
                stringInput = ""
            }
        } label: {
            VStack(spacing: 3) {
                Text(unit.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                Text(unit.fullName)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isSelected ? manager.activity.color : Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color(UIColor.separator),
                        lineWidth: 0.5
                    )
            }
        }
    }
    
    // MARK: - Helpers
    
    var decimalDisabled: Bool {
        stringInput.isEmpty || stringInput.contains(".")
    }
}

#Preview {
    FitnessTimeSelectorView(manager: MyDayNewFitnessManager(activity: .boxing))
}
