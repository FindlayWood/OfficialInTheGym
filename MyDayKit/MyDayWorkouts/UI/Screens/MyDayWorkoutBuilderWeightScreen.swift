//
//  MyDayWorkoutBuilderWeightScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/05/2026.
//

import SwiftUI

struct MyDayWorkoutBuilderWeightScreen: View {
    
    @ObservedObject var exercise: WorkoutExerciseBuilderManager
    @State private var selectedUnit: WeightUnit?
    @State private var value: Double = 0
    @State private var stringInput: String = ""
    @State private var selectedSetIndices: Set<Int> = []
    
    var continueAction: (() -> ())?
    
    private var allSetsMode: Bool { selectedSetIndices.isEmpty }
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Set selector ───────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All sets pill
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
                        let hasWeight = set.weight != nil && set.weightUnits != nil
                        
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
                                
                                if let weight = set.weight, let unit = set.weightUnits {
                                    if unit == .max || unit == .bw {
                                        Text(unit.rawValue)
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                                    } else {
                                        Text("\(weight.formatted(.number.precision(.fractionLength(0...2)))) \(unit.rawValue)")
                                            .font(.system(size: 11, weight: .regular))
                                            .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                }
                            }
                            .frame(width: 72, height: 52)
                            .background(isSelected ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(hasWeight && !isSelected ? Color.darkColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .padding(.vertical, 12)
            
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
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .animation(.easeInOut(duration: 0.2), value: selectedSetIndices)
            
            Divider()
            
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
            .padding(.vertical, 16)
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
                        applyToTargets()
                    },
                    selection: { number in
                        stringInput.append("\(number)")
                        value = Double(stringInput) ?? 0
                        applyToTargets()
                    },
                    backspace: {
                        stringInput.removeLast()
                        value = Double(stringInput) ?? 0
                        applyToTargets()
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.2), value: unit)
            }
            
            Spacer()
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                doneAction()
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValidSelection ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isValidSelection ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValidSelection)
            }
            .disabled(!isValidSelection)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle("Weight")
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
            applyToTargets()
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
        
        let units = targets.compactMap(\.weightUnits)
        let values = targets.compactMap(\.weight)
        
        // Only pre-fill if all targets share the same unit and value
        if units.count == targets.count,
           let firstUnit = units.first, units.allSatisfy({ $0 == firstUnit }) {
            selectedUnit = firstUnit
            if values.count == targets.count,
               let firstValue = values.first, values.allSatisfy({ $0 == firstValue }) {
                value = firstValue
                if firstUnit == .max || firstUnit == .bw {
                    stringInput = ""
                } else {
                    stringInput = firstValue.formatted(.number.precision(.fractionLength(0...2)))
                }
            } else {
                value = 0
                stringInput = ""
            }
        } else {
            selectedUnit = nil
            value = 0
            stringInput = ""
        }
    }
    
    private func applyToTargets() {
        guard let selectedUnit else { return }
        // Don't apply numeric units unless there's actually a value
        guard selectedUnit == .max || selectedUnit == .bw || value > 0 else { return }

        let targets = allSetsMode
            ? Array(exercise.sets.indices)
            : selectedSetIndices.sorted()

        for index in targets {
            exercise.sets[index].setWeight(value)
            exercise.sets[index].setWeightUnits(selectedUnit)
        }
        exercise.objectWillChange.send()
    }

    private func doneAction() {
        continueAction?()
    }
    
    var decimalDisabled: Bool {
        stringInput.isEmpty || stringInput.contains(".")
    }
}

#Preview {
    let exercise = WorkoutExerciseBuilderManager(exercise: .pressUps)
    exercise.addSets(4)
    return MyDayWorkoutBuilderWeightScreen(exercise: exercise)
}
