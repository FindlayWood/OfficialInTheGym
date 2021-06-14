//
//  AMRAPFirebaseAPIService.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class AMRAPFirebaseAPIService {
    
    static var shared = AMRAPFirebaseAPIService()
    
    private var ref = Database.database().reference()

    private init(){}
    
    func setStartTime(at position: Int, on workout: workout) {
        guard let userID = Auth.auth().currentUser?.uid,
              let workoutID = workout.workoutID
        else {return}
        let time = ServerValue.timestamp()
        ref.child("Workouts/\(userID)/\(workoutID)/exercises/\(position)/startTime").setValue(time)
    }
    func uploadExercisesCompleted(at position: Int, on workout: workout) {
        guard let userID = Auth.auth().currentUser?.uid,
              let workoutID = workout.workoutID
        else {return}
        let path = "Workouts/\(userID)/\(workoutID)/exercises/\(position)"
        ref.child(path).runTransactionBlock { (currentData) -> TransactionResult in
            if var amrapData = currentData.value as? [String:AnyObject] {
                var exercisesCompleted = amrapData["exercisesCompleted"] as? Int ?? 0
                exercisesCompleted += 1
                amrapData["exercisesCompleted"] = exercisesCompleted as AnyObject
                currentData.value = amrapData
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    func uploadRoundsCompleted(at position: Int, on workout: workout) {
        guard let userID = Auth.auth().currentUser?.uid,
              let workoutID = workout.workoutID
        else {return}
        let path = "Workouts/\(userID)/\(workoutID)/exercises/\(position)"
        ref.child(path).runTransactionBlock { (currentData) -> TransactionResult in
            if var amrapData = currentData.value as? [String:AnyObject] {
                var roundsCompleted = amrapData["roundsCompleted"] as? Int ?? 0
                roundsCompleted += 1
                amrapData["roundsCompleted"] = roundsCompleted as AnyObject
                currentData.value = amrapData
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    func startAMRAP(at position: Int, on workout: workout) {
        guard let userID = Auth.auth().currentUser?.uid,
              let workoutID = workout.workoutID
        else {return}
        let path = "Workouts/\(userID)/\(workoutID)/exercises/\(position)/started"
        ref.child(path).setValue(true)
    }
    func completeAMRAP(at position: Int, on workout: workout) {
        guard let userID = Auth.auth().currentUser?.uid,
              let workoutID = workout.workoutID
        else {return}
        let path = "Workouts/\(userID)/\(workoutID)/exercises/\(position)/completed"
        ref.child(path).setValue(true)
    }
}
