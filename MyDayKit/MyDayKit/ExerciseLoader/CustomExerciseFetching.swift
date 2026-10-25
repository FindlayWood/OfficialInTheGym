//
//  CustomExerciseFetching.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Reads the signed-in user's custom exercises from one store — the local
/// files or their Firestore copy. The picker reads both and merges them
/// (`ExerciseLibrary`), the read half of `CustomExerciseUploading`'s
/// local-first write.
public protocol CustomExerciseFetching {
    func fetchAll() async throws -> [CustomExercise]
}

/// Holds none, for previews and anything built without a store.
public struct EmptyCustomExerciseFetching: CustomExerciseFetching {
    public init() {}

    public func fetchAll() async throws -> [CustomExercise] {
        []
    }
}
