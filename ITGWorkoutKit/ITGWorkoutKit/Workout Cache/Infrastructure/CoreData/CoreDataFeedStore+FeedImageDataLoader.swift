//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 29/05/2024.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedWorkoutItem.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedWorkoutItem.first(with: url, in: context)?.data
            })
        }
    }

}
