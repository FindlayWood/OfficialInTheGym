//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 28/04/2023.
//

import SwiftUI

struct TempoSelectionSheet: View {
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    @Binding var selectedUnit: Units?
    
    @State private var selectedTime: Time?
    @State private var eccentric: String = ""
    @State private var eccentricHold: String = ""
    @State private var concentric: String = ""
    @State private var concentricHold: String = ""
    @State private var valueText: String = ""
    @State private var unitText: String = ""
    @FocusState var isFocused: FocusFields?
    
    enum FocusFields {
        case eccentric
        case eccentricHold
        case concentric
        case concentricHold
    }
    
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
                VStack {
                    TextField("", text: $eccentric)
                        .multilineTextAlignment(.center)
                        .focused($isFocused, equals: .eccentric)
                        .padding()
                        .background(Color(.darkColour))
                        .tint(.white)
                        .cornerRadius(8)
                        .onChange(of: eccentric) { [eccentric] newValue in
                            if newValue.count > 0 {
                                isFocused = .eccentricHold
                            }
                            if newValue.count > 1 {
                                self.eccentric = eccentric
                            }
                        }
                    Text("Eccentric")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
                VStack {
                    TextField("", text: $eccentricHold)
                        .multilineTextAlignment(.center)
                        .focused($isFocused, equals: .eccentricHold)
                        .padding()
                        .background(Color(.darkColour))
                        .tint(.white)
                        .cornerRadius(8)
                        .onChange(of: eccentricHold) { [eccentricHold] newValue in
                            if newValue.count > 0 {
                                isFocused = .concentric
                            }
                            if newValue.count > 1 {
                                self.eccentricHold = eccentricHold
                            }
                        }
                    Text("Pause")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
                VStack {
                    TextField("", text: $concentric)
                        .multilineTextAlignment(.center)
                        .focused($isFocused, equals: .concentric)
                        .padding()
                        .background(Color(.darkColour))
                        .tint(.white)
                        .cornerRadius(8)
                        .onChange(of: concentric) { [concentric] newValue in
                            if newValue.count > 0 {
                                isFocused = .concentricHold
                            }
                            if newValue.count > 1 {
                                self.concentric = concentric
                            }
                        }
                    Text("Concentric")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
                VStack {
                    TextField("", text: $concentricHold)
                        .multilineTextAlignment(.center)
                        .focused($isFocused, equals: .concentricHold)
                        .padding()
                        .background(Color(.darkColour))
                        .tint(.white)
                        .cornerRadius(8)
                        .onChange(of: concentricHold) { [concentricHold] newValue in
                            if newValue.count > 0 {
                                isFocused = nil
                            }
                            if newValue.count > 1 {
                                self.concentricHold = concentricHold
                            }
                        }
                    Text("Pause")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
            }
            .font(.title.bold())
            .foregroundColor(.white)
            
            if updateButtonEnabled {
                Button {
                    guard let e = Int(eccentric),
                          let eh = Int(eccentricHold),
                          let c = Int(concentric),
                          let ch = Int(concentricHold)
                    else {
                        return
                    }
                    let model = TempoModel(eccentric: e, eccentricHold: eh, concentric: c, concentricHold: ch)
                    viewModel.updateTempo(model)
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
        }
    }
    
    var updateButtonEnabled: Bool {
        !eccentric.isEmpty && !eccentricHold.isEmpty && !concentric.isEmpty && !concentricHold.isEmpty
        
    }
}

struct TempoSelectionSheet_Previews: PreviewProvider {
    static var previews: some View {
        TempoSelectionSheet(viewModel: ExerciseCreationHomeViewModel(workoutCreation: PreviewWorkoutCreation()), selectedUnit: .constant(.tempo))
    }
}
