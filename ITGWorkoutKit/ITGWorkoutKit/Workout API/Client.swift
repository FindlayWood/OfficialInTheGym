//
//  Client.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/03/2024.
//

import Foundation

public enum ClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
public protocol Client {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from path: String, completion: @escaping (ClientResult) -> Void)
}
