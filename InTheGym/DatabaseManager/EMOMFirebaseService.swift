//
//  EMOMFirebaseService.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

protocol EMOMFirebaseServiceProtocol {
    func completedEMOM(on workout: workout, at position: Int, completion: @escaping (Result<Void, Error>) -> Void)
    func uploadRPEScore(on workout: workout, at position: Int, with score: Int, completion: @escaping (Result<Void, Error>) -> Void)
}

class EMOMFirebaseService: EMOMFirebaseServiceProtocol {
    
    // MARK: - Properties
    var ref: DatabaseReference = Database.database().reference()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Shared Reference
    static let shared = EMOMFirebaseService()
    
    // MARK: - Functions
    
    func completedEMOM(on workout: workout, at position: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let workoutID = workout.workoutID else {return}
        let currentUserID = FirebaseAuthManager.currentlyLoggedInUser.uid
        let path = "Workouts/\(currentUserID)/\(workoutID)/exercises/\(position)/completed"
        let completedRef = ref.child(path)
        completedRef.setValue(true) { error, ref in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func uploadRPEScore(on workout: workout, at position: Int, with score: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let workoutID = workout.workoutID else {return}
        let currentUserID = FirebaseAuthManager.currentlyLoggedInUser.uid
        let path = "Workouts/\(currentUserID)/\(workoutID)/exercises/\(position)/rpe"
        let completedRef = ref.child(path)
        completedRef.setValue(score) { error, ref in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
