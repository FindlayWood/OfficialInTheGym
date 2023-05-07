//
//  File.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import Foundation

class WorkoutDisplayViewModel: ObservableObject {
    
    @Published var selectedSet: SetController?
    
    var workoutManager: WorkoutManager
    var workoutModel: RemoteWorkoutModel
    @Published var exercises: [ExerciseController] = []
    @Published var isLoadingExercises: Bool = false

    init(workoutManager: WorkoutManager, workoutModel: RemoteWorkoutModel) {
        self.workoutManager = workoutManager
        self.workoutModel = workoutModel
    }
    
    @MainActor
    func loadExercises() async {
        isLoadingExercises = true
        do {
            let exercises = try await workoutManager.loadExercises(for: workoutModel).sorted()
            self.exercises = exercises.map { ExerciseController(exerciseModel: $0) }
            isLoadingExercises = false
        } catch {
            print(String(describing: error))
            isLoadingExercises = false
        }
    }
    
    func setCompleted(_ model: SetModel) {
    }
}
