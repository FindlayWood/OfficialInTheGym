//
//  FirebaseLiveWorkoutUpdater.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FirebaseLiveWorkoutUpdater {
    
    static let shared = FirebaseLiveWorkoutUpdater()
    
    private init(){}
    
    private var path = Database.database().reference().child("Workouts")
    
    func update(_ workoutModel: WorkoutDelegate) {
        guard let userid = workoutModel.creatorID, let id = workoutModel.workoutID, let exercises = workoutModel.exercises else {return}
        let object = exercises.map {($0.toObject())}
        path.child(userid).child(id).updateChildValues(["exercises": object])
        
    }
}
