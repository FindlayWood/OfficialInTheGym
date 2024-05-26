//
//  RemoteExerciseLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public final class RemoteExerciseLoader: ExerciseLoader {
    
    private let client: ExerciseClient
    private let path: String
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = ExerciseLoader.Result
    
    public init(client: ExerciseClient, path: String) {
        self.client = client
        self.path = path
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: path) { [weak self] result  in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteExerciseLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ExerciseItemsMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
