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
    
    var workout : WorkoutDelegate!
    var circuitPosition : Int!
    let userID = Auth.auth().currentUser!.uid
    init(workout:WorkoutDelegate, position:Int){
        self.workout = workout
        self.circuitPosition = position
    }

    // MARK: - Actions
    
    func completedExercise(at indexPath:IndexPath){
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference().child("Workouts").child(userID).child(workout.workoutID!).child("exercises").child("\(circuitPosition!)").child("exercises").child("\(indexPath.section)").child("completedSets").child("\(indexPath.item)")
        ref.setValue(true)
    }
    
    func updateStats(for exercise: CircuitTableModel) {
        //TODO: update exercise stats
        FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exercise.exerciseName, reps: exercise.reps, weight: exercise.weight)
        
    }
    
    
    func completeCircuit(with rpe:Int){
        let ref = Database.database().reference().child("Workouts").child(self.userID).child(workout.workoutID!).child("exercises").child("\(circuitPosition!)")
        ref.child("rpe").setValue(rpe)
        ref.child("completed").setValue(true)
    }


    
}
