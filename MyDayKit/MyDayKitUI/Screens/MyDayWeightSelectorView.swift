//
//  MyDayWeightSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 26/08/2025.
//

import SwiftUI

struct MyDayWeightSelectorView: View {
    
    @State private var selectedUnit: WeightUnit?
    @State private var value: Double
    @State private var stringInput: String = ""
    
    private var isValidSelection: Bool {
        guard let unit = selectedUnit else { return false }
        return (unit == .max || unit == .bw) ? true : value > 0
    }
    
    private var isBodyweightUnit: Bool {
        selectedUnit == .max || selectedUnit == .bw
    }
    
    private var displayValue: String {
        guard let unit = selectedUnit else { return "–" }
        if unit == .max { return "Max" }
        if unit == .bw  { return "BW" }
        return stringInput.isEmpty ? "0" : stringInput
    }
    
    private var unitLabel: String {
        guard let unit = selectedUnit,
              unit != .max, unit != .bw else { return "" }
        return unit.rawValue
    }
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    let newExercise: MyDayNewExerciseManager
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._selectedUnit = State(initialValue: newExercise.weightUnits)
        self._value = State(initialValue: newExercise.weight ?? 0)
        if let existing = newExercise.weight, existing > 0 {
            self._stringInput = State(initialValue: "\(existing.formatted(.number.precision(.fractionLength(0...2))))")
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Weight")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("Select a unit and enter a value")
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
                        isValidSelection
                            ? Color.primary
                            : Color(UIColor.tertiaryLabel)
                    )
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: stringInput)
                
                if !unitLabel.isEmpty {
                    Text(unitLabel)
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
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    unitButton(unit)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            // ── Number pad ─────────────────────────────────────────────
            if let unit = selectedUnit, unit != .max, unit != .bw {
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
                .animation(.easeInOut(duration: 0.2), value: unit)
            }
            
            Spacer()
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction()
            } label: {
                Group {
                    if isValidSelection, let unit = selectedUnit {
                        if unit == .max || unit == .bw {
                            Text("Add \(unit.rawValue)")
                        } else {
                            Text("Add \(stringInput) \(unit.rawValue)")
                        }
                    } else {
                        Text("Select a unit")
                    }
                }
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
    
    // MARK: - Unit Button
    
    @ViewBuilder
    private func unitButton(_ unit: WeightUnit) -> some View {
        let isSelected = selectedUnit == unit
        let isBodyweight = unit == .max || unit == .bw
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if unit == selectedUnit {
                    selectedUnit = nil
                } else {
                    selectedUnit = unit
                }
                if isBodyweight {
                    value = 0
                    stringInput = ""
                }
            }
        } label: {
            VStack(spacing: 4) {
                Text(unit.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                if isBodyweight {
                    Text("no value")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isSelected ? Color.darkColor : Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.darkColor : Color(UIColor.separator),
                        lineWidth: isSelected ? 0 : 0.5
                    )
            }
        }
    }
    
    // MARK: - Helpers
    
    func addAction() {
        guard let selectedUnit else { return }
        newExercise.setWeight(value)
        newExercise.setWeightUnits(selectedUnit)
        continueAction?()
    }
    
    var decimalDisabled: Bool {
        stringInput.isEmpty || stringInput.contains(".")
    }
}

private extension Double {
    var cleanString: String {
        self.truncatingRemainder(dividingBy: 1) == 0 ?
        String(format: "%.0f", self) : String(self)
    }
}

#Preview {
    MyDayWeightSelectorView(newExercise: .init(exercise: .pressUps))
}
