//
//  WorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 03/03/2024.
//

import Foundation

enum LoadWorkoutsResult {
    case success([WorkoutItem])
    case error(Error)
}


protocol WorkoutLoader {
    func load(completion: @escaping (LoadWorkoutsResult) -> Void)
}
