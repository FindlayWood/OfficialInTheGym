//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 28/04/2023.
//

import SwiftUI

struct RestTimeSelectionSheet: View {
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    @Binding var selectedUnit: Units?
    
    @State private var selectedTime: Time?
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
                TextField("time", text: $valueText)
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
            
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                ForEach(Time.allCases, id:\.title) { unit in
                    Button {
                        toggleSelected(unit)
                    } label: {
                        Text(unit.title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedTime == unit ? (Color(.darkColour)) : Color(.lightColour))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            if updateButtonEnabled {
                Button {
                    if let unit = selectedTime, let value = Double(valueText)  {
                        viewModel.updateRestTime(TimeModel(unit: unit, value: value))
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
    
    func toggleSelected(_ time: Time) {
        if selectedTime == time {
            selectedTime = nil
            unitText = ""
        } else {
            selectedTime = time
            unitText = time.title
            isFocused = true
        }
    }
    
    var updateButtonEnabled: Bool {
        if selectedTime != nil, !valueText.isEmpty {
            return true
        } else {
            return false
        }
    }
}

struct RestTimeSelectionSheet_Previews: PreviewProvider {
    static var previews: some View {
        RestTimeSelectionSheet(viewModel: ExerciseCreationHomeViewModel(workoutViewModel: WorkoutCreationHomeViewModel()), selectedUnit: .constant(.restime))
    }
}
