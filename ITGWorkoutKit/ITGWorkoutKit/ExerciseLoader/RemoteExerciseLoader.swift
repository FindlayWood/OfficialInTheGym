//
//  RemoteExerciseLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public typealias RemoteExerciseLoader = RemoteLoader<[ExerciseItem]>

public extension RemoteExerciseLoader {
    convenience init(client: Client, path: String) {
        self.init(client: client, path: path, mapper: ExerciseItemsMapper.map)
    }
}
