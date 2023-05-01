//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 26/04/2023.
//

import SwiftUI

struct WeightSelectionSheet: View {
    
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    @Binding var selectedUnit: Units?
    
    @State private var selectedWeight: Weight?
    @State private var weightValue: String = ""
    @State private var unitText: String = ""
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    selectedUnit = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.darkColour))
                }
            }
            HStack {
                TextField("weight", text: $weightValue)
                    .tint(.white)
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
                    .disabled(weightFieldDisabled)
                TextField("", text: $unitText)
                    .multilineTextAlignment(.leading)
                    .disabled(true)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color(.darkColour))
            .clipShape(Capsule())
            .padding()
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                ForEach(Weight.allCases, id:\.title) { unit in
                    Button {
                        toggleSelectedWeight(unit)
                    } label: {
                        Text(unit.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedWeight == unit ? (Color(.darkColour)) : Color(.lightColour))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            if updateButtonEnabled {
                Button {
                    if let unit = selectedWeight {
                        viewModel.updateWeight(WeightModel(unit: unit, value: Double(weightValue)))
                    }
                } label: {
                    if let selectedSet = viewModel.selectedSetModel {
                        Text("Update Set \(selectedSet.setNumber + 1)")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    } else {
                        Text("Update All Sets")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                }
                .opacity(updateButtonEnabled ? 1: 0)
                .disabled(!updateButtonEnabled)
                .padding()
            }
        }
        .animation(.easeInOut, value: updateButtonEnabled)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 2)
        )
        .padding()
    }
    
    func toggleSelectedWeight(_ weight: Weight) {
        if selectedWeight == weight {
            selectedWeight = nil
            unitText = ""
        } else {
            selectedWeight = weight
            unitText = weight.title
            if weight != .max || weight != .bodyweight {
                isFocused = true
            }
        }
        if weight == .max || weight == .bodyweight {
            isFocused = false
            weightValue = ""
        }
    }
    
    var updateButtonEnabled: Bool {
        if let selectedWeight {
            switch selectedWeight {
            case .max, .bodyweight:
                return true
            case .kilograms, .pounds:
                return !(weightValue.isEmpty)
            case .bodyweightPercentage, .maxPercentage:
                return !(weightValue.isEmpty)
            }
        } else {
            return false
        }
    }
    var weightFieldDisabled: Bool {
        selectedWeight == .max || selectedWeight == .bodyweight
    }
}

struct WeightSelectionSheet_Previews: PreviewProvider {
    static var previews: some View {
        WeightSelectionSheet(viewModel: ExerciseCreationHomeViewModel(workoutViewModel: WorkoutCreationHomeViewModel()), selectedUnit: .constant(.weight))
    }
}
