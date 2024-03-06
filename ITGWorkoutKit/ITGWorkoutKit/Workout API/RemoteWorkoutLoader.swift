//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public protocol FirestoreClient {
    func get(from path: String)
}

public final class RemoteWorkoutLoader {
    
    private let client: FirestoreClient
    private let path: String
    
    public init(client: FirestoreClient, path: String) {
        self.client = client
        self.path = path
    }
    
    public func load() {
        client.get(from: path)
    }
}


