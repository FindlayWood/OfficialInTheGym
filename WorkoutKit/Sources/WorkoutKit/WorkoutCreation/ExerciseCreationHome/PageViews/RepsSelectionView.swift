//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import SwiftUI

struct RepsSelectionView: View {
    
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.setModels) { model in
                            Button {
                                viewModel.toggleSetSelected(model)
                                withAnimation {
                                    value.scrollTo(model.setNumber)
                                }
                            } label: {
                                VStack {
                                    Text("Set \(model.setNumber + 1)")
                                    Text("\(model.reps) Reps")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(viewModel.selectedSetModel == model ? Color(.darkColour) : Color(.lightColour))
                                .cornerRadius(8)
                                .id(model.setNumber)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            Text("Reps")
                .font(.largeTitle.bold())
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.selectedReps -= 1
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(.darkColour))
                    }
                    Spacer()
                    Text(viewModel.selectedReps, format: .number)
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    Button {
                        viewModel.selectedReps += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(.darkColour))
                    }
                    Spacer()
                }
                .padding()
                if let selectedSet = viewModel.selectedSetModel {
                    Text("Select the number of reps for set \(selectedSet.setNumber + 1).")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                } else {
                    Text("Select the number of reps for all sets.")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1..<100) { number in
                            Button {
                                viewModel.selectedReps = number
                            } label: {
                                Text(number, format: .number)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(viewModel.selectedReps == number ? Color(.darkColour) : Color(.lightColour))
                                    .clipShape(Circle())
                                    .id(number)
                            }
                        }
                    }
                    .padding()
                }
                .animation(.easeInOut, value: viewModel.sets)
                .onChange(of: viewModel.selectedReps) { newValue in
                    withAnimation {
                        value.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }
}

struct RepsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RepsSelectionView(viewModel: ExerciseCreationHomeViewModel(workoutCreation: PreviewWorkoutCreation()))
    }
}
