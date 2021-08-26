//
//  FirebaseDatabaseManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseDatabaseWorkoutManagerService {
    func post(from endpoint: WorkoutEndpoint, completion: @escaping (Result<WorkoutDelegate, Error>) -> Void)
}

class FirebaseDatabaseWorkoutManager: FirebaseDatabaseWorkoutManagerService {
    
    static let shared = FirebaseDatabaseWorkoutManager()
    
    var databaseReference: DatabaseReference
    
    private init() {
        databaseReference = Database.database().reference()
    }
    
    func post(from endpoint: WorkoutEndpoint, completion: @escaping (Result<WorkoutDelegate, Error>) -> Void) {
        databaseReference = databaseReference.child(endpoint.path).childByAutoId()
        guard let workoutID = databaseReference.key else {return}
        var uploadData = endpoint.workout
        uploadData.workoutID = workoutID
        let uploadObject = uploadData.convertToUploadWorkout()
        databaseReference.setValue(uploadObject) { error, ref in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(uploadData))
            }
        }
    }
}
