//
//  DescriptionModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Description Model
///Model for exercise description
class ExerciseCommentModel: DisplayableComment, Codable, Hashable {

    var id: String
    var exercise: String
    var username: String
    var posterID: String
    var time: TimeInterval
    var comment: String
    var likeCount: Int
    var replyCount: Int
    
    init(exercise: String, comment: String) {
        self.id = UUID().uuidString
        self.exercise = exercise
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
    
    static func == (lhs: ExerciseCommentModel, rhs: ExerciseCommentModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
extension ExerciseCommentModel: FirebaseInstance {
    var internalPath: String {
        return "ExerciseComments/\(exercise)/\(id)"
    }
    var myDescriptionsPath: String {
        return "MyComments/\(UserDefaults.currentUser.uid)/\(exercise)/\(id)"
    }
    var votePath: String {
        return "ExerciseComments/\(exercise)/\(id)/likeCount"
    }
    var myVotesDescriptionPath: String {
        return "MyCommentLikes/\(UserDefaults.currentUser.uid)/\(id)"
    }
}

// MARK: - ExerciseCommentSearchModel
/// Model to search for all descriptions for a given exercise
struct ExerciseCommentSearchModel {
    var exercise: String
}
extension ExerciseCommentSearchModel: FirebaseInstance {
    var internalPath: String {
        return "ExerciseComments/\(exercise)"
    }
}

// MARK: - Vote Search Model
/// Search if current user has liked comment
struct CommentLikeSearchModel {
    var commentID: String
    var userID: String
}
extension CommentLikeSearchModel: FirebaseInstance {
    var internalPath: String {
        return "MyCommentLikes/\(userID)/\(commentID)"
    }
}
