//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import SwiftUI

struct WorkoutDisplayView: View {
    
    @ObservedObject var viewModel: WorkoutDisplayViewModel
    
    @Namespace var namespace
    
    var body: some View {
        VStack {
            if viewModel.isLoadingExercises {
                VStack {
                    Image(systemName: "network")
                        .font(.largeTitle)
                        .foregroundColor(Color(.white))
                    Text("Loading Exercises")
                        .font(.title.bold())
                        .foregroundColor(Color(.white))
                    Text("Wait 1 second, we are just loading the exercises for this workout!")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    ProgressView()
                }
            } else {
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.clear)
                ScrollView {
                    VStack {
                        ForEach(viewModel.exercises) { model in
                            WorkoutExerciseView(exercise: model, selectedSet: $viewModel.selectedSet, namespace: namespace)
                                .environmentObject(viewModel)
                        }
                    }
                    .padding(6)
                }
            }
        }
        .animation(.easeInOut, value: viewModel.exercises)
        .background(Color(.lightColour))
        .overlay {
            if let select = viewModel.selectedSet {
                ExpandedSetView(selectedSet: select.set, exercise: select.exercise, namespace: namespace) {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                        viewModel.selectedSet = nil
                    }
                }
                .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
            }
        }
        .task {
            await viewModel.loadExercises()
        }
    }
}

struct WorkoutDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDisplayView(viewModel: WorkoutDisplayViewModel(workoutManager: PreviewWorkoutManager(), workoutModel: .example))
    }
}
