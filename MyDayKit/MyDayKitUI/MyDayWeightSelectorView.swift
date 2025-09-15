//
//  MyDayWeightSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 26/08/2025.
//

import SwiftUI

struct MyDayWeightSelectorView: View {
    
    @State private var selectedUnit: WeightUnit? = nil
    @State private var value: Int = 0
    
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
                    Text(" \(value) \(unit.rawValue)")
                        .font(.system(size: 30, weight: .bold))
                    
                    HStack(spacing: 24) {
                        // Negative side
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(steps, id: \.self) { step in
                                Button(action: {
                                    value = max(0, value - step)
                                }) {
                                    Text("-\(step)")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.red.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Positive side
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(steps, id: \.self) { step in
                                Button(action: {
                                    value = min(9999, value + step)
                                }) {
                                    Text("+\(step)")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color.green.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
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
