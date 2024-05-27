//
//  RemoteWorkoutLoader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 06/03/2024.
//

import Foundation

public typealias RemoteWorkoutLoader = RemoteLoader<[WorkoutItem]>

public extension RemoteWorkoutLoader {
    convenience init(client: Client, path: String) {
        self.init(client: client, path: path, mapper: WorkoutItemsMapper.map)
    }
}
