//
//  TagModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct TagModel: Codable {
    var tagName: String
    var exercises: [String: String]
}
struct TagExerciseReturnModel: Codable, Hashable {
    var exerciseName: String
}

struct TagSearchModel: FirebaseQueryModel {
    var equalTo: String = ""
    
    var orderedBy: String {
        return "tagName"
    }
    
    var internalPath: String {
        return "Tags"
    }
}

struct ExerciseTagSearchModel {
    var exerciseName: String
}
extension ExerciseTagSearchModel: FirebaseInstance {
    var internalPath: String {
        "ExerciseTags/\(exerciseName)"
    }
}

struct ExerciseTagReturnModel: Decodable, Hashable {
    var tag: String
    var id: String = UUID().uuidString
}

struct ExerciseTagUploadModel: Encodable {
    var exerciseName: String
    var tag: String
    var id: String = UUID().uuidString
    
    var uploadPoint: [FirebaseMultiUploadDataPoint] {
        [FirebaseMultiUploadDataPoint(value: tag, path: tagPath),FirebaseMultiUploadDataPoint(value: id, path: idPath)]
    }
}
extension ExerciseTagUploadModel {
    var tagPath: String {
        "ExerciseTags/\(exerciseName)/\(id)/tag"
    }
    var idPath: String {
        "ExerciseTags/\(exerciseName)/\(id)/id"
    }
}

struct TagUploadModel {
    var exerciseName: String
    var tag: String
    
    var points: [FirebaseMultiUploadDataPoint] {
        [FirebaseMultiUploadDataPoint(value: tag, path: namePath),FirebaseMultiUploadDataPoint(value: exerciseName, path: exercisePath)]
    }
}
extension TagUploadModel {
    var namePath: String {
        "Tags/\(tag)/tagName"
    }
    var exercisePath: String {
        "Tags/\(tag)/exercises/\(UUID().uuidString)"
    }
}
