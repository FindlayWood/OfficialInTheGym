//
//  LocalFeedImageDataLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 29/05/2024.
//

import Foundation

public final class LocalFeedImageDataLoader {

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result<Void, Swift.Error>

    public func save(_ data: Data, for path: String, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: path) { _ in }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from path: String, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForPath: path) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound) })
        }
        return task
    }
}
