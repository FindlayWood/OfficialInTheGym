//
//  RemoteWorkoutItem2.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 05/05/2024.
//

import Foundation

internal struct RemoteWorkoutItem2: Decodable {
    internal let id: String
    internal let title: String
    internal let exerciseCount: Int
    internal let createdUID: String
    internal let createdDate: Date
    internal let addedToListDate: Date
}
