//
//  MyDayDistanceSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 30/10/2025.
//

import SwiftUI

enum DistanceUnit: String, CaseIterable, Codable {
    case metres = "m"
    case kilometres = "km"
    case miles = "mi"
}

struct MyDayDistanceSelectorView: View {
    
    @State private var selectedUnit: DistanceUnit?
    @State private var value: Double
    @State private var stringInput: String = ""
    
    private var isValidSelection: Bool {
        guard selectedUnit != nil else { return false }
        return value > 0
    }
    
    private var displayValue: String {
        stringInput.isEmpty ? "0" : stringInput
    }
    
    private var unitLabel: String {
        selectedUnit?.rawValue ?? ""
    }
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    let newExercise: MyDayNewExerciseManager
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._selectedUnit = State(initialValue: newExercise.distanceUnits)
        self._value = State(initialValue: newExercise.distance ?? 0)
        if let existing = newExercise.distance, existing > 0 {
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
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction()
            } label: {
                Group {
                    if isValidSelection, let unit = selectedUnit {
                        Text("Add \(stringInput) \(unit.rawValue)")
                    } else if selectedUnit != nil {
                        Text("Enter a distance")
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
                        ? Color.blue
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
    private func unitButton(_ unit: DistanceUnit) -> some View {
        let isSelected = selectedUnit == unit
        
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if unit == selectedUnit {
                    selectedUnit = nil
                } else {
                    selectedUnit = unit
                }
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
            .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
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
    
    func addAction() {
        guard let selectedUnit else { return }
        newExercise.setDistance(value)
        newExercise.setDistanceUnits(selectedUnit)
        continueAction?()
    }
    
    var decimalDisabled: Bool {
        stringInput.isEmpty || stringInput.contains(".")
    }
}

// MARK: - DistanceUnit extension

extension DistanceUnit {
    var fullName: String {
        switch self {
        case .metres:     return "Metres"
        case .kilometres: return "Kilometres"
        case .miles:      return "Miles"
        }
    }
}


#Preview {
    MyDayDistanceSelectorView(newExercise: .init(exercise: .pressUps))
}
