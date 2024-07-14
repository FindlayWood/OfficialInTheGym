//
//  WorkoutFeedItem.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 13/07/2024.
//

import Foundation

public struct WorkoutFeedItem: Equatable {
    
    public let id: UUID
    public let addedToListDate: Date
    public let createdDate: Date
    public let creatorID: String
    public let exerciseCount: Int
    public let savedWorkoutID: UUID
    public let title: String
    
    public init(id: UUID, addedToListDate: Date, createdDate: Date, creatorID: String, exerciseCount: Int, savedWorkoutID: UUID, title: String) {
        self.id = id
        self.addedToListDate = addedToListDate
        self.createdDate = createdDate
        self.creatorID = creatorID
        self.exerciseCount = exerciseCount
        self.savedWorkoutID = savedWorkoutID
        self.title = title
    }
}
