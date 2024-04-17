//
//  WorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 03/03/2024.
//

import Foundation

public typealias LoadWorkoutsResult = Result<[WorkoutItem],Error>

public protocol WorkoutLoader {
    func load(completion: @escaping (LoadWorkoutsResult) -> Void)
}
