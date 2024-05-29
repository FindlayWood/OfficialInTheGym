//
//  LocalFeedLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/04/2024.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

}

extension LocalFeedLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [WorkoutItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [WorkoutItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }

            completion(insertionError)
        }
    }
}

extension LocalFeedLoader: WorkoutLoader {
    
    public typealias LoadResult = WorkoutLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))

            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in completion(.success(())) }
            
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in completion(.success(())) }

            case .success:
                completion(.success(()))
            }
        }
    }
}

private extension Array where Element == WorkoutItem {
    func toLocal() -> [LocalWorkoutItem] {
        return map { LocalWorkoutItem(id: $0.id, description: $0.description, location: $0.location, image: $0.image) }
    }
}

private extension Array where Element == LocalWorkoutItem {
    func toModels() -> [WorkoutItem] {
        return map { WorkoutItem(id: $0.id, description: $0.description, location: $0.location, image: $0.image) }
    }
}
