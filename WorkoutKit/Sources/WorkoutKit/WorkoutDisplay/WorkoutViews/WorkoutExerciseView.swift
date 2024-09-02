//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 01/05/2023.
//

import SwiftUI

struct WorkoutExerciseView: View {

    @ObservedObject var exercise: ExerciseController
    
    @Binding var selectedSet: SelectedSet?
    
    let namespace: Namespace.ID
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                
            } label: {
                Text(exercise.name)
                    .font(.title.bold())
                    .foregroundColor(.primary)
            }
            .padding()
            
            Divider()
                .padding(.horizontal)
            
            HStack {
                Text("\(exercise.sets.count) Sets")
                    .font(.headline)
                Spacer()
                Text(exercise.type.title)
                    .font(.headline)
            }
            .padding(.horizontal)
            HStack {
                ForEach(exercise.sets) { setModel in
                    Text(setModel.reps, format: .number)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.leading)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(exercise.sets) { setModel in
                        if let selectedSet, selectedSet.set == setModel {
                            EmptySetView(model: setModel)
                        } else {
                            WorkoutSetView(model: setModel, namespace: namespace)
                                .environmentObject(exercise)
                                .onTapGesture {
                                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                                        selectedSet = .init(set: setModel, exercise: exercise)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            
            Divider()
                .padding(.horizontal)
            
            HStack {
                Button {
                    
                } label: {
                    Text("Note")
                        .font(.headline)
                        .foregroundColor(Color(.darkColour))
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.headline)
                        .foregroundColor(Color(.darkColour))
                }
                Spacer()
                Button {
                    
                } label: {
                    Text("RPE")
                        .font(.headline)
                        .foregroundColor(Color(.darkColour))
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.vertical)
    }
}

struct WorkoutExerciseView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        WorkoutExerciseView(exercise: .example, selectedSet: .constant(.example), namespace: namespace)
    }
}
