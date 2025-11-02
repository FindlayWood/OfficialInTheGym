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
    @State private var value: Int
    
    private var isValidSelection: Bool {
        guard selectedUnit != nil else { return false }
        // All distance units require a numeric value
        return value > 0
    }
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    let steps: [Int] = [1, 5, 10, 50, 100, 500]
    
    let newExercise: MyDayNewExerciseManager
    
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._selectedUnit = State(initialValue: newExercise.distanceUnits)
        self._value = State(initialValue: newExercise.distance ?? 0)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Unit selection grid
            Text("Select Distance Unit")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DistanceUnit.allCases, id: \.self) { unit in
                    Button(action: {
                        if unit == selectedUnit {
                            selectedUnit = nil
                        } else {
                            selectedUnit = unit
                        }
                        value = 0 // reset when changing unit
                    }) {
                        Text(unit.rawValue.uppercased())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedUnit == unit ? Color.blue : Color.gray.opacity(0.1))
                            .foregroundColor(selectedUnit == unit ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            // Numeric input controls
            if let unit = selectedUnit {
                VStack(spacing: 16) {
                    Text("\(value) \(unit.rawValue)")
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
                                    value = min(999_999, value + step)
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
            newExercise.setDistance(value)
            newExercise.setDistanceUnits(selectedUnit)
            continueAction?()
        }
    }
}


#Preview {
    MyDayDistanceSelectorView(newExercise: .init(exercise: .pressUps))
}
