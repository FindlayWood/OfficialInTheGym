//
//  WorkoutEndoints.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

enum WorkoutEndpoints: WorkoutEndpoint {
    
    case postWorkout(id: String, workout: WorkoutDelegate, service: FirebaseDatabaseWorkoutManagerService)
    case postGroupWorkout(id: String, workout: WorkoutDelegate, service: FirebaseDatabaseWorkoutManagerService)
    
    var path: String {
        switch self {
        case .postWorkout(let id, _, _):
            return "Workouts/\(id)"
        case .postGroupWorkout(let id, _, _):
            return "GroupWorkouts/\(id)"
        }
    }
    
    var workout: WorkoutDelegate {
        switch self {
        case .postWorkout(_, let workout, _):
            return workout
        case .postGroupWorkout(_, let workout, _):
            return workout
        }
    }
    
    var service: FirebaseDatabaseWorkoutManagerService {
        switch self {
        case .postWorkout(_, _, let service):
            return service
        case .postGroupWorkout(_, _, let service):
            return service
        }
    }
}
extension WorkoutEndpoints {
    func post(completion: @escaping (Result<WorkoutDelegate, Error>) -> Void) {
        service.post(from: self, completion: completion)
    }
}
