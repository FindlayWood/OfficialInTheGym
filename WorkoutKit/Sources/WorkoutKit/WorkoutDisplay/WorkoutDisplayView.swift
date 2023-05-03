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
        .background(Color(.lightColour))
        .overlay {
            if let select = viewModel.selectedSet {
                ExpandedSetView(selectedSet: select, namespace: namespace) {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                        viewModel.selectedSet = nil
                    }
                }
                .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
            }
        }
    }
}

struct WorkoutDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDisplayView(viewModel: WorkoutDisplayViewModel(workoutModel: .example, exercises: [.example]))
    }
}
