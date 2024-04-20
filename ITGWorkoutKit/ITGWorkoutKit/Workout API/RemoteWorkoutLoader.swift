//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public final class RemoteWorkoutLoader: WorkoutLoader {
    
    private let client: Client
    private let path: String
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = WorkoutLoader.Result
    
    public init(client: Client, path: String) {
        self.client = client
        self.path = path
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: path) { [weak self] result  in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteWorkoutLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try WorkoutItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteWorkoutItem {
    func toModels() -> [WorkoutItem] {
        return map { WorkoutItem(id: $0.id, description: $0.description, location: $0.location, image: $0.image) }
    }
}
