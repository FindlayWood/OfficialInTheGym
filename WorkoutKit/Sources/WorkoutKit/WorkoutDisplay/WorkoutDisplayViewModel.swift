//
//  File.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import Foundation

class WorkoutDisplayViewModel: ObservableObject {
    
    @Published var selectedSet: SelectedSet?
    
    var workoutManager: WorkoutManager
    var workoutModel: RemoteWorkoutModel
    var networkService: NetworkService
    @Published var exercises: [ExerciseController] = []
    @Published var isLoadingExercises: Bool = false

    init(workoutManager: WorkoutManager, workoutModel: RemoteWorkoutModel, networkService: NetworkService) {
        self.workoutManager = workoutManager
        self.workoutModel = workoutModel
        self.networkService = networkService
    }
    
    @MainActor
    func loadExercises() async {
        exercises = workoutModel.exercises.map { ExerciseController(exerciseModel: $0) }
//        isLoadingExercises = true
//        do {
//            let exercises = try await workoutManager.loadExercises(for: workoutModel).sorted()
//            self.exercises = exercises.map { ExerciseController(exerciseModel: $0) }
//            isLoadingExercises = false
//        } catch {
//            print(String(describing: error))
//            isLoadingExercises = false
//        }
    }
    
    func setCompleted(_ model: SetController, on exercise: ExerciseController) {
        let path = "Workouts/\(workoutModel.assignedTo)/\(workoutModel.id)/exercises/\(exercise.workoutPosition)/sets/\(model.setNumber)/completed"
        print(path)
        Task {
            do {
                try await networkService.write(data: true, at: path)
            } catch {
                print(String(describing: error))
            }
        }
//        let path = "Users/\(workoutModel.assignedTo)/Workouts/\(workoutModel.id)/Exercises/\(exercise.id)"
//        
//        print(exercise.id)
//        print(exercise.workoutPosition)
//        print(model.setNumber)
//        print(model.id)
    }
}

struct SelectedSet {
    var set: SetController
    var exercise: ExerciseController
    static let example = SelectedSet(set: .example, exercise: .example)
}
