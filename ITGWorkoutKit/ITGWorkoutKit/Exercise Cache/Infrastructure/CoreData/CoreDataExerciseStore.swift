//
//  CoreDataExerciseStore.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 26/05/2024.
//

import CoreData

public final class CoreDataExerciseStore: ExerciseStore {
    
    private static let modelName = "ExerciseStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataExerciseStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        guard let model = CoreDataExerciseStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataExerciseStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedExerciseCache.find(in: context).map {
                    return CachedExerciseList(list: $0.localList, timestamp: $0.timestamp)
                }
            })
        }
    }

    public func insert(_ feed: [LocalExerciseItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedExerciseCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.list = ManagedExerciseItem.exercises(from: feed, in: context)
                try context.save()
            })
        }
    }

    public func deleteCachedList(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedExerciseCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }

}
