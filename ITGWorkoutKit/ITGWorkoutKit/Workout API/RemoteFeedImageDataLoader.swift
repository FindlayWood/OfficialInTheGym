//
//  RemoteFeedImageDataLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 28/05/2024.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private let client: Client
    
    public enum Error: Swift.Error {
        case invalidData
    }

    public init(client: Client) {
        self.client = client
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    @discardableResult
    public func loadImageData(from path: String, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        
        task.wrapped = client.get(from: path) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    task.complete(with: .success(data))
                } else {
                    task.complete(with: .failure(Error.invalidData))
                }
            case let .failure(error): task.complete(with: .failure(error))
            }
        }
        
        return task
    }
}
