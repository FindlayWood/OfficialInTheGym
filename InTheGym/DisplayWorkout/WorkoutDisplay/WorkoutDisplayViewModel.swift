//
//  WorkoutDisplayViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class WorkoutDisplayViewModel {
    
    // MARK: - Properties
    var workout: SavedWorkoutModel!
    
    lazy var exercises: [ExerciseType] = {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: workout.exercises ?? [])
        exercises.append(contentsOf: workout.circuits ?? [])
        exercises.append(contentsOf: workout.amraps ?? [])
        exercises.append(contentsOf: workout.emoms ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }()
    
    func getAllExercises() -> [ExerciseType] {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: workout.exercises ?? [])
        exercises.append(contentsOf: workout.circuits ?? [])
        exercises.append(contentsOf: workout.amraps ?? [])
        exercises.append(contentsOf: workout.emoms ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }
    
    func completeSet(at index: IndexPath) {
        print(index)
        if let exerciseIndex = workout.exercises?.firstIndex(where: {$0.workoutPosition == index.section }) {
            print(exerciseIndex)
            workout.exercises?[exerciseIndex].completedSets[index.item] = true
        }
        
//        let exercise = exercises[index.item] as! ExerciseModel
//        exercise.completedSets[index.section] = true
    }
}
