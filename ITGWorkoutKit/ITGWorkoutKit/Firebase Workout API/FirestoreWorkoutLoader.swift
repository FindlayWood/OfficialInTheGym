//
//  FirestoreWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 05/05/2024.
//

import Foundation

public final class FirestoreWorkoutLoader: WorkoutLoader2 {
    
    private let client: WorkoutClient
    private let path: String
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = WorkoutLoader2.Result
    
    public init(client: WorkoutClient, path: String) {
        self.client = client
        self.path = path
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: path) { [weak self] result  in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(FirestoreWorkoutLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try WorkoutItemsMapper2.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteWorkoutItem2 {
    func toModels() -> [WorkoutItem2] {
        return map { WorkoutItem2(id: $0.id, title: $0.title, exerciseCount: $0.exerciseCount, createdUID: $0.createdUID, createdDate: $0.createdDate, addedToListDate: $0.addedToListDate) }
    }
}
