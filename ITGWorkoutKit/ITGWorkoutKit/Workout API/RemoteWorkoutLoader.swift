//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}
public protocol FirestoreClient {
    func get(from path: String, completion: @escaping (HTTPClientResult) -> Void)
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
        client.get(from: path) { result  in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}


