//
//  RemoteExerciseItem.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public struct RemoteExerciseItem: Decodable {
    let id: UUID
    let name: String
    let bodyArea: String
}
