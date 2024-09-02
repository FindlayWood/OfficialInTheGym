//
//  WorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 03/03/2024.
//

import Foundation

public protocol WorkoutLoader {
    typealias Result = Swift.Result<[WorkoutItem],Error>
    
    func load(completion: @escaping (Result) -> Void)
}
