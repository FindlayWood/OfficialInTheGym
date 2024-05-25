//
//  WorkoutBuilder.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public class WorkoutBuilder {
    
    public var title: String = ""
    public var exercises: [ExerciseModel] = []
    public var tags: [TagModel] = []
    public var isSaving: Bool = true
    public var isPublic: Bool = true
    
    public var creationErrors: [CreateWorkoutError] = []
    
    public enum CreateWorkoutError {
        case noExercises
        case noTitle
    }
    
    public init() {
        
    }
    
    public func updateTitle(_ newTitle: String) {
        title = newTitle
    }
        
    public var maxTagCount: Int {
        10
    }
    
    public func addTag(_ newTag: TagModel) {
        if tags.count < maxTagCount {
            tags.append(newTag)
        }
    }
    
    public func updatePrivacy(_ newIsPublic: Bool) {
        isPublic = newIsPublic
    }

    public func updateSaving(_ newIsSaving: Bool) {
        isSaving = newIsSaving
    }
    
    public func addExercise(_ model: ExerciseModel) {
        exercises.append(model)
    }
    
    public func createWorkout() {
        if exercises.isEmpty {
            creationErrors.append(.noExercises)
        }
        if title.count < 4 {
            creationErrors.append(.noTitle)
        }
    }
}
