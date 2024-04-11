//
//  FeedStore.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 11/04/2024.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalWorkoutItem], timestamp: Date, completion: @escaping InsertionCompletion)
}


