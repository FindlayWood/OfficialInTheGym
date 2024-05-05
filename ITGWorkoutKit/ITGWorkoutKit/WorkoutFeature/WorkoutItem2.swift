//
//  WorkoutItem2.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 05/05/2024.
//

import Foundation

public struct WorkoutItem2: Hashable {
    public let id: String
    public let title: String
    public let exerciseCount: Int
    public let createdUID: String
    public let createdDate: Date
    public let addedToListDate: Date
    
    public init(id: String, title: String, exerciseCount: Int, createdUID: String, createdDate: Date, addedToListDate: Date) {
        self.id = id
        self.title = title
        self.exerciseCount = exerciseCount
        self.createdUID = createdUID
        self.createdDate = createdDate
        self.addedToListDate = addedToListDate
    }
}
