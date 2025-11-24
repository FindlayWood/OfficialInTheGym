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
        if unit == .max || unit == .bw {
            return true
        } else {
            return value > 0
        }
    }
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    let steps: [Int] = [1, 2, 5, 10, 15, 20]
    
    let newExercise: MyDayNewExerciseManager
    
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._selectedUnit = State(initialValue: newExercise.weightUnits)
        self._value = State(initialValue: newExercise.weight ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Unit selection grid
            Text("Select Weight Unit")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    Button(action: {
                        if unit == selectedUnit {
                            selectedUnit = nil
                        } else {
                            selectedUnit = unit
                        }
                        if unit == .max || unit == .bw {
                            value = 0 // reset value if Max or BW
                        }
                    }) {
                        Text(unit.rawValue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedUnit == unit ? Color.blue : Color.gray.opacity(0.1))
                            .foregroundColor(selectedUnit == unit ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            // Numeric input controls
            if let unit = selectedUnit, unit != .max, unit != .bw {
                VStack(spacing: 16) {
                    Text("\(stringInput.isEmpty ? "0" : stringInput) \(unit.rawValue)")
                        .font(.system(size: 30, weight: .bold))
                    
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
                }
            } else if selectedUnit == .max {
                Text("MAX")
                    .font(.system(size: 30, weight: .bold))
            } else if selectedUnit == .bw {
                Text("BW")
                    .font(.system(size: 30, weight: .bold))
            }
            
            Spacer()
            
            // Continue button
            Button {
                addAction()
            } label: {
                Text("Add")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidSelection ? Color.blue : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValidSelection)
            
        }
        .padding()
    }
    
    func addAction() {
        if let selectedUnit {
            newExercise.setWeight(value)
            newExercise.setWeightUnits(selectedUnit)
            continueAction?()
        }
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
