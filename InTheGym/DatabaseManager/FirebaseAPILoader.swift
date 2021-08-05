//
//  FirebaseAPILoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAPILoader {
    
    typealias escapingSavedWorkout = Result<discoverWorkout,LoaderErrors>
    typealias escapingWorkoutStats = Result<WorkoutStatsModel,LoaderErrors>
    typealias escapingExerciseStats = Result<[DisplayExerciseStatsModel],LoaderErrors>
    
    static let shared = FirebaseAPILoader()
    
    private init() {}
    
    private let baseRef = Database.database().reference()
    
    func loadDiscoverWorkout(with savedID: String, completion: @escaping (escapingSavedWorkout) -> Void) {
        let path = "SavedWorkouts/\(savedID)"
        let ref = baseRef.child(path)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let discoverWorkout = discoverWorkout(snapshot: snapshot) else {
                completion(.failure(.noSavedWorkout))
                return
            }
            completion(.success(discoverWorkout))
        }
    }
    
    func loadWorkoutStats(with savedID: String, completion: @escaping (escapingWorkoutStats) -> Void) {
        let path = "SavedWorkouts/\(savedID)"
        let ref = baseRef.child(path)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let workoutStats = WorkoutStatsModel(snapshot: snapshot) else {
                completion(.failure(.noSavedWorkout))
                return
            }
            completion(.success(workoutStats))
        }
    }
    
    func loadExerciseStats(completion: @escaping (escapingExerciseStats) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(.noUserID))
            return
        }
        var tempStats = [DisplayExerciseStatsModel]()
        let path = "ExerciseStats/\(userID)"
        let ref = baseRef.child(path)
        ref.observe(.childAdded) { snapshot in
            guard let _ = snapshot.value as? [String: AnyObject] else {
                completion(.failure(.noSavedWorkout))
                return
            }
            guard let stat = DisplayExerciseStatsModel(snapshot: snapshot) else {
                completion(.failure(.noSavedWorkout))
                return
            }
            tempStats.append(stat)
        }
        
        ref.observeSingleEvent(of: .value) { _ in
            completion(.success(tempStats))
        }
    }
}

enum LoaderErrors: Error {
    case noUserID
    case noSavedWorkout
    case unKnown
}
