//
//  WorkoutTagModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct WorkoutTagModel {
    var tags: [ExerciseTagReturnModel]
    var savedWorkoutModel: SavedWorkoutModel
    
    func getPoints() -> [FirebaseMultiUploadDataPoint] {
        var points: [FirebaseMultiUploadDataPoint] = []
        for tag in tags {
            let idPath = "WorkoutTags/\(savedWorkoutModel.id)/\(tag.id)/id"
            let tagPath = "WorkoutTags/\(savedWorkoutModel.id)/\(tag.id)/tag"
            let tagMainPath = "Tags/\(tag.tag)/workouts/\(UUID().uuidString)"
            let tagNameMainPath = "Tags/\(tag.tag)/tagName"
            points.append(FirebaseMultiUploadDataPoint(value: tag.id, path: idPath))
            points.append(FirebaseMultiUploadDataPoint(value: tag.tag, path: tagPath))
            points.append(FirebaseMultiUploadDataPoint(value: savedWorkoutModel.id, path: tagMainPath))
            points.append(FirebaseMultiUploadDataPoint(value: tag.tag, path: tagNameMainPath))
        }
        return points
    }
    func getSinglePoint(from singleTag: ExerciseTagReturnModel) -> [FirebaseMultiUploadDataPoint] {
        var points: [FirebaseMultiUploadDataPoint] = []
        let idPath = "WorkoutTags/\(savedWorkoutModel.id)/\(singleTag.id)/id"
        let tagPath = "WorkoutTags/\(savedWorkoutModel.id)/\(singleTag.id)/tag"
        let tagMainPath = "Tags/\(singleTag.tag)/workouts/\(UUID().uuidString)"
        let tagNameMainPath = "Tags/\(singleTag.tag)/tagName"
        points.append(FirebaseMultiUploadDataPoint(value: singleTag.id, path: idPath))
        points.append(FirebaseMultiUploadDataPoint(value: singleTag.tag, path: tagPath))
        points.append(FirebaseMultiUploadDataPoint(value: savedWorkoutModel.id, path: tagMainPath))
        points.append(FirebaseMultiUploadDataPoint(value: singleTag.tag, path: tagNameMainPath))
        return points
    }
}
/// model to search for all tags given to a saved workout
struct WorkoutTagSearchModel {
    /// the id of the saved workout model
    var savedWorkoutID: String
}
extension WorkoutTagSearchModel: FirebaseInstance {
    /// the path within firebase including the saved workout id
    var internalPath: String {
        "WorkoutTags/\(savedWorkoutID)"
    }
}
