//
//  ManagedExerciseCache.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 26/05/2024.
//

import CoreData

@objc(ManagedExerciseCache)
internal class ManagedExerciseCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var list: NSOrderedSet
}

extension ManagedExerciseCache {
    internal static func find(in context: NSManagedObjectContext) throws -> ManagedExerciseCache? {
        let request = NSFetchRequest<ManagedExerciseCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    internal static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedExerciseCache {
        try find(in: context).map(context.delete)
        return ManagedExerciseCache(context: context)
    }
    
    internal var localList: [LocalExerciseItem] {
        return list.compactMap { ($0 as? ManagedExerciseItem)?.local }
    }
}
