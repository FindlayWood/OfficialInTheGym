//
//  WorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 03/03/2024.
//

import Foundation

public enum LoadWorkoutsResult<Error: Swift.Error> {
    case success([WorkoutItem])
    case failure(Error)
}

protocol WorkoutLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadWorkoutsResult<Error>) -> Void)
}
