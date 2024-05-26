//
//  LocalExerciseLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public final class LocalExerciseLoader {
    
    private let store: ExerciseStore
    private let currentDate: () -> Date
    
    public init(store: ExerciseStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

}

extension LocalExerciseLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ list: [ExerciseItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedList { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(list, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ list: [ExerciseItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(list.toLocal(), timestamp: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }

            completion(insertionError)
        }
    }
}

extension LocalExerciseLoader: ExerciseLoader {
    
    public typealias LoadResult = ExerciseLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where ExerciseCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.list.toModels()))

            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalExerciseLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedList { _ in }
            
            case let .success(.some(cache)) where !ExerciseCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedList { _ in }

            case .success: break
            }
        }
    }
}

private extension Array where Element == ExerciseItem {
    func toLocal() -> [LocalExerciseItem] {
        return map { LocalExerciseItem(id: $0.id, name: $0.name, bodyArea: $0.bodyArea) }
    }
}

private extension Array where Element == LocalExerciseItem {
    func toModels() -> [ExerciseItem] {
        return map { ExerciseItem(id: $0.id, name: $0.name, bodyArea: $0.bodyArea) }
    }
}
