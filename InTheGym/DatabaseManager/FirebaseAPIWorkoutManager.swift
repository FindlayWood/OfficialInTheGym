//
//  FirebaseAPIWorkoutManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAPIWorkoutManager {
    
    static var shared = FirebaseAPIWorkoutManager()
    private init() {}
    private let baseRef = Database.database().reference()
    
    private let kilogramSuffix = "kg"
    private let poundsSuffix = "lbs"
    
    private let repStatString = "numberOfRepsCompleted"
    private let setStatString = "numberOfSetsCompleted"
    private let totalWeightStatString = "totalWeight"
    private let maxWeightStatString = "maxWeight"
    private let maxWeightDateStatString = "maxWeightDate"
    private let rpeStatString = "totalRPE"
    private let completionStatString = "numberOfCompletions"
    private let exerciseNameString = "exerciseName"
    
    func checkMaxWeight(exercise: String, weight: Double) {
        let path = "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exercise)"
        let ref = baseRef.child(path)
        
        ref.runTransactionBlock { currentData in
            if var stats = currentData.value as? [String:AnyObject] {
                let maxWeight = stats[self.maxWeightStatString] as? Double ?? 0.0
                if weight > maxWeight {
                    stats[self.maxWeightStatString] = weight as AnyObject
                    stats[self.maxWeightDateStatString] = Date().timeIntervalSince1970 as AnyObject
                    self.updateMaxHistory(exercise: exercise, weight: weight)
                } else if weight == 0.0 {
                    stats[self.maxWeightStatString] = weight as AnyObject
                }
                currentData.value = stats
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    

//MARK: Workout & Exercise Stats Methods
    func checkForExerciseStats(name: String, reps: Int, weight: String?) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let path = "ExerciseStats/\(userID)/\(name)"
        let ref = baseRef.child(path)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.updateExerciseStats(name: name, reps: reps, weight: weight)
            } else {
                self.addExerciseStats(name: name, reps: reps, weight: weight)
            }
        }
    }
    func checkForCompletionStats(name: String, rpe: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let path = "ExerciseStats/\(userID)/\(name)"
        let ref = baseRef.child(path)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.completeExercise(name: name, with: rpe)
            } else {
                self.addCompletionStats(name: name, rpe: rpe)
            }
        }
    }
    
    
    private func updateExerciseStats(name: String, reps: Int, weight: String?) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let path = "ExerciseStats/\(userID)/\(name)"
        let ref = baseRef.child(path)
        
        ref.runTransactionBlock { currentData in
            if var stats = currentData.value as? [String:AnyObject] {
                var repStat = stats[self.repStatString] as? Int ?? 0
                var sets = stats[self.setStatString] as? Int ?? 0
                repStat += reps
                sets += 1
                stats[self.repStatString] = repStat as AnyObject
                stats[self.setStatString] = sets as AnyObject
                if let weightString = weight {
                    var totalWeight = stats[self.totalWeightStatString] as? Double ?? 0
                    let maxWeight = stats[self.maxWeightStatString] as? Double ?? 0
                    let weightNumber = self.getWeight(from: self.poundsOrKilograms(from: weightString) ?? .kg(0.0))
                    totalWeight += weightNumber
                    stats[self.totalWeightStatString] = totalWeight as AnyObject
                    if weightNumber > maxWeight {
                        stats[self.maxWeightStatString] = weightNumber as AnyObject
                        stats[self.maxWeightDateStatString] = Date().timeIntervalSince1970 as AnyObject
                        self.updateMaxHistory(exercise: name, weight: weightNumber)
                    }
                }
                currentData.value = stats
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Update max history
    private func updateMaxHistory(exercise: String, weight: Double) {
        let userID = FirebaseAuthManager.currentlyLoggedInUser.uid
        let currentTime = Date().timeIntervalSince1970
        let path =  "ExerciseMaxHistory/\(userID)/\(exercise)"
        let ref = baseRef.child(path).childByAutoId()
        let data = ["time": currentTime,
                    "weight": weight] as [String : Any]
        ref.setValue(data)
    }
    
    private func addExerciseStats( name: String, reps: Int, weight: String?) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let path = "ExerciseStats/\(userID)/\(name)"
        let ref = baseRef.child(path)
        var newData = [String: AnyObject]()
        newData[self.repStatString] = reps as AnyObject
        newData[self.setStatString] = 1 as AnyObject
        newData[self.exerciseNameString] = name as AnyObject
        newData[self.completionStatString] = 0 as AnyObject
        if let weightString = weight {
            let weightNumber = self.getWeight(from: self.poundsOrKilograms(from: weightString) ?? .kg(0.0))
            newData[self.totalWeightStatString] = weightNumber as AnyObject
            newData[self.maxWeightStatString] = weightNumber as AnyObject
            if weightNumber > 0.0 {
                self.updateMaxHistory(exercise: name, weight: weightNumber)
            }
        } else {
            newData[self.totalWeightStatString] = 0.0 as AnyObject
            newData[self.maxWeightStatString] = 0.0 as AnyObject
        }
        ref.setValue(newData)
    }
    private func completeExercise(name: String, with rpe: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let path = "ExerciseStats/\(userID)/\(name)"
        let ref = baseRef.child(path)
        
        ref.runTransactionBlock { currentData in
            if var stats = currentData.value as? [String: AnyObject] {
                var totalRPE = stats[self.rpeStatString] as? Int ?? 0
                var completions = stats[self.completionStatString] as? Int ?? 0
                totalRPE += rpe
                completions += 1
                stats[self.rpeStatString] = totalRPE as AnyObject
                stats[self.completionStatString] = completions as AnyObject
                currentData.value = stats
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, committed, snapshot in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    private func addCompletionStats(name: String, rpe: Int) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let path = "ExerciseStats/\(userID)/\(name)"
        let ref = baseRef.child(path)
        var newData = [String: AnyObject]()
        newData[self.rpeStatString] = rpe as AnyObject
        newData[self.completionStatString] = 1 as AnyObject
        ref.setValue(newData)
        
    }
    private func convertToKG(from pounds: Double) -> Double {
        return pounds / 2.205
    }
    private func poundsOrKilograms(from string: String) -> Weight? {
        let lastTwoChar = string.suffix(2)
        let lastThreeChar = string.suffix(3)
        if lastTwoChar == kilogramSuffix {
            let weightString = string.dropLast(2)
            if let weight = Double(weightString) {
                return .kg(weight)
            } else {
                return nil
            }
        } else if lastThreeChar == poundsSuffix {
            let weightString = string.dropLast(3)
            if let weight = Double(weightString) {
                return .lbs(weight)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    private func getWeight(from weight: Weight) -> Double {
        switch weight {
        case.kg(let kilos):
            return kilos
        case .lbs(let pounds):
            return convertToKG(from: pounds)
        }
    }
    
    
// MARK: LiveWorkout Methods
    func startLiveWorkout(with title: String, completion: @escaping (liveWorkout?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return}
        let workoutRef = baseRef.child("Workouts").child(userID).childByAutoId()
        let workoutID = workoutRef.key!
        let workoutData = ["completed":false,
                           "createdBy":ViewController.username!,
                           "title":title,
                           "startTime":Date.timeIntervalSinceReferenceDate,
                           "liveWorkout": true,
                           "creatorID":userID,
                           "workoutID":workoutID,
                           "fromDiscover":false,
                           "assigned":false] as [String : AnyObject]
        
        workoutRef.setValue(workoutData) { error, snapshot in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else {
                guard let workoutModel = liveWorkout(data: workoutData) else {
                    completion(nil)
                    return}
                completion(workoutModel)
            }
        }
    }
}

enum Weight {
    case kg(Double)
    case lbs(Double)
}
