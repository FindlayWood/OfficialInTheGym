//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public protocol FirestoreClient {
    func get(from path: String, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteWorkoutLoader {
    
    private let client: FirestoreClient
    private let path: String
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: FirestoreClient, path: String) {
        self.client = client
        self.path = path
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: path) { error, response  in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        }
    }
}


