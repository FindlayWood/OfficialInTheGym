//
//  FeedStore.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/04/2024.
//

import Foundation


public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalWorkoutItem], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalWorkoutItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}


