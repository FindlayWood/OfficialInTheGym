//
//  DiscussionModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Comment
struct Comment: Codable, Hashable {
    var id: String
    var username: String
    var time: TimeInterval
    var message: String
    var posterID: String
    var postID: String
    var attachedWorkoutSavedID: String?
}
extension Comment: FirebaseInstance {
    var internalPath: String {
        return "PostReplies/\(postID)/\(id)"
    }
}

struct UploadCommentModel {
    var comment: Comment
    
    func uploadPoints() -> [FirebaseMultiUploadDataPoint] {
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: replyCountPath))
        if let commentPoint = comment.toFirebaseJSON() {
            points.append(commentPoint)
        }
        return points
    }
}

extension UploadCommentModel {
    var replyCountPath: String {
        return "Posts/\(comment.postID)/replyCount"
    }
}


// MARK: - Group Comment Upload Model
struct UploadGroupCommentModel {
    var comment: Comment
    var groupID: String
    
    func uploadPoints() -> [FirebaseMultiUploadDataPoint] {
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: replyCountPath))
        if let commentPoint = comment.toFirebaseJSON() {
            points.append(commentPoint)
        }
        return points
    }
}
extension UploadGroupCommentModel {
    var replyCountPath: String {
        return "GroupPosts/\(groupID)/\(comment.postID)/replyCount"
    }
}
