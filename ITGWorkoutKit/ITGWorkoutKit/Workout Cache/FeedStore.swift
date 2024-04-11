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

public struct LocalWorkoutItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL?
    
    public init(id: UUID, description: String?, location: String?, image: URL?) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
}
