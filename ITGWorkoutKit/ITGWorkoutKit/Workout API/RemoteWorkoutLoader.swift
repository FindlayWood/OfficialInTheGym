//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public enum ClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}
public protocol Client {
    func get(from path: String, completion: @escaping (ClientResult) -> Void)
}

public final class RemoteWorkoutLoader {
    
    private let client: Client
    private let path: String
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: Client, path: String) {
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


