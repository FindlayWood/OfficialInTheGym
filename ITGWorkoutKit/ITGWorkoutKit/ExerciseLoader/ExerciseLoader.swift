//
//  ExerciseLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public protocol ExerciseLoader {
    typealias Result = Swift.Result<[ExerciseItem],Error>
    
    func load(completion: @escaping (Result) -> Void)
}
