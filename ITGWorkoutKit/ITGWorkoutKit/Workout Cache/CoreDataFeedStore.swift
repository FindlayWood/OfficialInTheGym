//
//  CoreDataFeedStore.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 16/04/2024.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ feed: [LocalWorkoutItem], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

}


private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedWorkoutItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
