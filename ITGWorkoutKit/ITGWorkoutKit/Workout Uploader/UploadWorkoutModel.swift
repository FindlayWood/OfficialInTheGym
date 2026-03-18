//
//  UploadWorkoutModel.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public struct UploadWorkoutModel {
    public let title: String
    public let exercises: [ExerciseModel]
    public let tags: [TagModel]
    public let isPublic: Bool
    public let savedID: String
    public let createdByID: String
    public let id: String
    
    public init(title: String, exercises: [ExerciseModel], tags: [TagModel], isPublic: Bool, savedID: String, createdByID: String, id: String) {
        self.title = title
        self.exercises = exercises
        self.tags = tags
        self.isPublic = isPublic
        self.savedID = savedID
        self.createdByID = createdByID
        self.id = id
    }
}
