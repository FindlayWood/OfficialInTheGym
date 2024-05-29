//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 29/05/2024.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for path: String, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            guard let image = try? ManagedWorkoutItem.first(with: path, in: context) else { return }
            
            image.data = data
            try? context.save()
        }
    }

    public func retrieve(dataForPath path: String, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                return try ManagedWorkoutItem.first(with: path, in: context)?.data
            })
        }
    }

}
