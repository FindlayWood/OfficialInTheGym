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
        case connectivity
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
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
            
        }
        
        return task
    }
}
