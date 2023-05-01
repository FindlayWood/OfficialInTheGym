//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 28/04/2023.
//

import SwiftUI

struct DistanceSelectionSheet: View {
    
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    @Binding var selectedUnit: Units?
    
    @State private var selectedDistance: Distance?
    @State private var valueText: String = ""
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
                TextField("distance", text: $valueText)
                    .tint(.white)
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
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
                ForEach(Distance.allCases, id:\.title) { unit in
                    Button {
                        toggleSelected(unit)
                    } label: {
                        Text(unit.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedDistance == unit ? (Color(.darkColour)) : Color(.lightColour))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            if updateButtonEnabled {
                Button {
                    if let unit = selectedDistance, let value = Double(valueText)  {
                        viewModel.updateDistance(DistanceModel(unit: unit, value: value))
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
    
    func toggleSelected(_ distance: Distance) {
        if selectedDistance == distance {
            selectedDistance = nil
            unitText = ""
        } else {
            selectedDistance = distance
            unitText = distance.title
            isFocused = true
        }
    }
    
    var updateButtonEnabled: Bool {
        if selectedDistance != nil, !valueText.isEmpty {
            return true
        } else {
            return false
        }
    }
}

struct DistanceSelectionSheet_Previews: PreviewProvider {
    static var previews: some View {
        DistanceSelectionSheet(viewModel: ExerciseCreationHomeViewModel(workoutViewModel: WorkoutCreationHomeViewModel()), selectedUnit: .constant(.distance))
    }
}
