//
//  Client.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/03/2024.
//

import Foundation

public protocol Client {
    typealias Result = Swift.Result<(Data,HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from path: String, completion: @escaping (Result) -> Void)
}
