//
//  WorkoutCommentModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Workout Comment Model
/// Model for workout comment
class WorkoutCommentModel: DisplayableComment, Codable, Hashable {
    
    var id: String
    var savedWorkoutModel: SavedWorkoutModel
    var username: String
    var posterID: String
    var time: TimeInterval
    var comment: String
    var likeCount: Int
    var replyCount: Int
    
    init(model: SavedWorkoutModel, comment: String) {
        self.id = UUID().uuidString
        self.savedWorkoutModel = model
        self.username = UserDefaults.currentUser.username
        self.posterID = UserDefaults.currentUser.uid
        self.time = Date().timeIntervalSince1970
        self.comment = comment
        self.likeCount = 0
        self.replyCount = 0
    }
    
    func uploadPoints() -> [FirebaseMultiUploadDataPoint] {
        guard let data = self.toFirebaseJSON() else {return []}
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(data)
        points.append(FirebaseMultiUploadDataPoint(value: true, path: myDescriptionsPath))
        return points
    }
    
    func votePoints() -> [FirebaseMultiUploadDataPoint] {
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: votePath))
        points.append(FirebaseMultiUploadDataPoint(value: true, path: myVotesDescriptionPath))
        return points
    }
    
    static func == (lhs: WorkoutCommentModel, rhs: WorkoutCommentModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension WorkoutCommentModel: FirebaseInstance {
    var internalPath: String {
        return "WorkoutComments/\(savedWorkoutModel.id)/\(id)"
    }
    var myDescriptionsPath: String {
        return "MyComments/\(UserDefaults.currentUser.uid)/\(savedWorkoutModel.id)/\(id)"
    }
    var votePath: String {
        return "WorkoutComments/\(savedWorkoutModel.id)/\(id)/likeCount"
    }
    var myVotesDescriptionPath: String {
        return "MyCommentLikes/\(UserDefaults.currentUser.uid)/\(id)"
    }
}
