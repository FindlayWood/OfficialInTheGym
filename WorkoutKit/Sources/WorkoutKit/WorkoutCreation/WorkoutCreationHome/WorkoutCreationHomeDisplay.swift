//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import SwiftUI

struct WorkoutCreationHomeDisplay: View {
    
    @ObservedObject var viewModel: WorkoutCreationHomeViewModel
    @State private var isShowingOptions: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "dumbbell")
                    .foregroundColor(Color(.darkColour))
                TextField("workout title...", text: $viewModel.title)
                    .tint(Color(.darkColour))
            }
            .padding()
            .background(.white)
            .clipShape(Capsule())
            .shadow(radius: 8)
            .padding()
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            if viewModel.exercises.isEmpty {
                VStack {
                    ZStack {
                        Image(systemName: "dumbbell.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(.darkColour))
                        Image(systemName: "nosign")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.red.opacity(0.5))
                    }
                    Text("No Exercises")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Text("No exercises, tap the + button to add the first exercise.")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button {
                        viewModel.addNewExerciseAction()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(.darkColour).opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
            } else {
                ZStack(alignment: .bottomTrailing) {
                    List {
                        Section {
                            if viewModel.exercises.isEmpty {
                                Text("No exercises, tap the + button to add the first exercise.")
                                    .font(.footnote.bold())
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(viewModel.exercises) { model in
                                    VStack(alignment: .leading) {
                                        Text(model.name)
                                            .font(.headline)
                                        Text("\(model.sets.count) sets")
                                            .font(.footnote.bold())
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        } header: {
                            Text("Exercises")
                        }
                    }
                    Button {
                        viewModel.addNewExerciseAction()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(.darkColour))
                    }
                    .padding()
                }
            }
            
            Divider()
            
            Button {
                isShowingOptions.toggle()
            } label: {
                Text("more options")
                    .font(.headline)
                    .foregroundColor(Color(.darkColour))
            }
            .padding()
            
            if viewModel.canCreateWorkout {
                Button {
                    viewModel.createNewWorkoutAction()
                } label: {
                    Text("Create Workout")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(.darkColour))
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                }
                .padding()
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: viewModel.canCreateWorkout)
//        .background(Color(.systemBackground))
        .sheet(isPresented: $isShowingOptions) {
            OptionsSheet(viewModel: viewModel)
                .presentationDragIndicator(.visible)
        }
    }
    
}

struct WorkoutCreationHomeDisplay_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutCreationHomeDisplay(viewModel: WorkoutCreationHomeViewModel())
    }
}
