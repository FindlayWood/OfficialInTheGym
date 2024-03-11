//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public enum ClientResult {
    case success(Data, HTTPURLResponse)
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
    
    public enum Result: Equatable {
        case success([WorkoutItem])
        case failure(Error)
    }
    
    public init(client: Client, path: String) {
        self.client = client
        self.path = path
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: path) { result  in
            switch result {
            case let .success(data, _):
                if let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [WorkoutItem]
}
