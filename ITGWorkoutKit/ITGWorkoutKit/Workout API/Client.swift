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
    func get(from path: String, completion: @escaping (ClientResult) -> Void)
}
