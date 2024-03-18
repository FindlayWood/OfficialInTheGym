//
//  WorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 03/03/2024.
//

import Foundation

public enum LoadWorkoutsResult {
    case success([WorkoutItem])
    case failure(Error)
}

protocol WorkoutLoader {
    func load(completion: @escaping (LoadWorkoutsResult) -> Void)
}
