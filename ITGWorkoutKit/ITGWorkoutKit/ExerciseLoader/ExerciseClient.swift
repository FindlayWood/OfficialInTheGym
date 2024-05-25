//
//  ExerciseClient.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public protocol ExerciseClient {
    typealias Result = Swift.Result<(Data,HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from path: String, completion: @escaping (Result) -> Void)
}
