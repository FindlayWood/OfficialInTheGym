//
//  ManagedWorkoutItem.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 16/04/2024.
//

import CoreData

@objc(ManagedWorkoutItem)
internal class ManagedWorkoutItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL?
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedWorkoutItem {
    internal static func workouts(from localFeed: [LocalWorkoutItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedWorkoutItem(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.image
            return managed
        })
    }

    internal var local: LocalWorkoutItem {
        return LocalWorkoutItem(id: id, description: imageDescription, location: location, image: url)
    }
}
