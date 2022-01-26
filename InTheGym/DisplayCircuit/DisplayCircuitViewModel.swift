//
//  DisplayCircuitViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class DisplayCircuitViewModel{
    
    // MARK: - Properties
    var circuitModel: CircuitModel!
    
    var workoutModel: WorkoutModel!
    
    lazy var tableModels: [CircuitTableModel] = circuitModel.intergrate()
    
    var apiService: FirebaseDatabaseManagerService

    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared){
        self.apiService = apiService
    }

    // MARK: - Actions
    
    func completedExercise(at indexPath: IndexPath){
//        let userID = Auth.auth().currentUser!.uid
//        let ref = Database.database().reference().child("Workouts").child(userID).child(workout.workoutID!).child("exercises").child("\(circuitPosition!)").child("exercises").child("\(indexPath.section)").child("completedSets").child("\(indexPath.item)")
//        ref.setValue(true)
    }
    
    func updateStats(for exercise: CircuitTableModel) {
        //TODO: update exercise stats
//        FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exercise.exerciseName, reps: exercise.reps, weight: exercise.weight)
        
    }
    
    
    func completeCircuit(with rpe: Int){
//        let ref = Database.database().reference().child("Workouts").child(self.userID).child(workout.workoutID!).child("exercises").child("\(circuitPosition!)")
//        ref.child("rpe").setValue(rpe)
//        ref.child("completed").setValue(true)
    }


    // MARK: - Retrieve Functions
    func isInteractionEnabled() -> Bool {
        if workoutModel.startTime != nil && !workoutModel.completed {
            return true
        } else {
            return false
        }
    }
    func getModel(at indexPath: IndexPath) -> CircuitTableModel {
        return tableModels[indexPath.section]
    }
    func retreiveNumberOfExercises() -> Int {
        return tableModels.count
    }
}
