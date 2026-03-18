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
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedWorkoutItem {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedWorkoutItem? {
        let request = NSFetchRequest<ManagedWorkoutItem>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedWorkoutItem.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
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
