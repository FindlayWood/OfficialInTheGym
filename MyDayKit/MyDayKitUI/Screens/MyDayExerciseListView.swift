//
//  MyDayExerciseListView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/07/2025.
//

import SwiftUI

struct MyDayExerciseListView: View {
    
    @State private var selectedCategory: ExerciseCategory = .upperBody
    @State private var searchText: String = ""
    
    @ObservedObject var exerciseManager: ExerciseManager
    
    var selectedExercise: ((MyDayNewExerciseManager) -> ())?
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            exerciseManager.exercises.filter { $0.category == selectedCategory }
        } else {
            exerciseManager.exercises.filter { $0.category == selectedCategory && $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            if selectedCategory == cat {
                                Text(cat.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .background {
                                        Color
                                            .blue
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                            } else {
                                Text(cat.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.primary)
                                    .padding()
                                    .background {
                                        Color
                                            .blue.opacity(0.1)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                            }
                            
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("search exercises...", text: $searchText)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                }
            }
            .padding()
            .background {
                Color.black.opacity(0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
            
            if exerciseManager.isLoading {
                VStack {
                    ProgressView()
                    Text("loading...")
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredExercises, id: \.name) { exercise in
                        Button {
                            let newExercise = MyDayNewExerciseManager(exercise: exercise)
                            selectedExercise?(newExercise)
                        } label: {
                            Text(exercise.name)
                        }
                    }
                }
            }
        }
        .task {
            await exerciseManager.load()
        }
    }
}

#Preview {
    MyDayExerciseListView(exerciseManager: ExerciseManager(loader: PreviewExerciseLoader()))
}
