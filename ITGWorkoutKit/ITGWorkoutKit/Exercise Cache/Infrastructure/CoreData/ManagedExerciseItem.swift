//
//  ManagedExerciseItem.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 26/05/2024.
//

import CoreData

@objc(ManagedExerciseItem)
internal class ManagedExerciseItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var bodyArea: String
    @NSManaged var cache: ManagedExerciseCache
}

extension ManagedExerciseItem {
    internal static func exercises(from localList: [LocalExerciseItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localList.map { local in
            let managed = ManagedExerciseItem(context: context)
            managed.id = local.id
            managed.name = local.name
            managed.bodyArea = local.bodyArea
            return managed
        })
    }

    internal var local: LocalExerciseItem {
        return LocalExerciseItem(id: id, name: name, bodyArea: bodyArea)
    }
}
