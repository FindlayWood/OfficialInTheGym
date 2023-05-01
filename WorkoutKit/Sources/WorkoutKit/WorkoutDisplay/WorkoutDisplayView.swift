//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import SwiftUI

struct WorkoutDisplayView: View {
    
    @ObservedObject var viewModel: WorkoutDisplayViewModel
    
    @State private var selectedSet: SetModel?
    
    @Namespace var namespace
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.exercises) { model in
                    WorkoutExerciseView(exercise: model, selectedSet: $selectedSet, namespace: namespace)
                }
            }
            .padding(6)
        }
        .background(Color(.lightColour))
        .overlay(
            ExpandedSetView(selectedSet: $selectedSet, namespace: namespace)
                .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
        )   
    }
}

struct WorkoutDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDisplayView(viewModel: WorkoutDisplayViewModel(workoutModel: .example, exercises: [.example]))
    }
}
