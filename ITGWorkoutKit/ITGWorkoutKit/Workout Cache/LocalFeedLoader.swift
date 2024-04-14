//
//  LocalFeedLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/04/2024.
//

import Foundation

private final class FeedCachePolicy {
    
    /// there never needs to be an instance of this policy
    /// there is no identity - it is just a policy
    private init() {}
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

}

extension LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    public func save(_ feed: [WorkoutItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [WorkoutItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }

            completion(error)
        }
    }
}

extension LocalFeedLoader: WorkoutLoader {
    
    public typealias LoadResult = LoadWorkoutsResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))

            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            
            case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }

            case .empty, .found: break
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
