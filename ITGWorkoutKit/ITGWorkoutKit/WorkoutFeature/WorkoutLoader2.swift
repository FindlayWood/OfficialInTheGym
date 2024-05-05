//
//  WorkoutLoader2.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 05/05/2024.
//

import Foundation

public protocol WorkoutLoader2 {
    typealias Result = Swift.Result<[WorkoutItem2],Error>
    
    func load(completion: @escaping (Result) -> Void)
}
