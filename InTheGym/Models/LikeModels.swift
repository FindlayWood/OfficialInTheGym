//
//  LikeModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct PostLikesModel {
    var postID: String
    
    func toMultiUploadPoint(with value: Bool) -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: value, path: internalPath)
    }
}
extension PostLikesModel: FirebaseInstance {
    var internalPath: String {
        return "PostLikes/\(postID)/\(FirebaseAuthManager.currentlyLoggedInUser.uid)"
    }
}

struct LikesModel {
    var postID: String
    
    func toMultiUploadPoint(with value: Bool) -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: value, path: internalPath)
    }
}
extension LikesModel: FirebaseInstance {
    var internalPath: String {
        return "Likes/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(postID)"
    }
}

struct LikeCount {
    var postID: String
    
    func toMultiUploadPoint(increment: Bool) -> FirebaseMultiUploadDataPoint {
        if increment {
            return FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: internalPath)
        } else {
            return FirebaseMultiUploadDataPoint(value: ServerValue.increment(-1), path: internalPath)
        }
    }
}
extension LikeCount: FirebaseInstance {
    var internalPath: String {
        return "Posts/\(postID)/likeCount"
    }
}

struct LikeTransportLayer {
    var postID: String

    func multiPoints(increasing: Bool) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        uploadPoints.append(PostLikesModel(postID: postID).toMultiUploadPoint(with: increasing))
        uploadPoints.append(LikesModel(postID: postID).toMultiUploadPoint(with: increasing))
        uploadPoints.append(LikeCount(postID: postID).toMultiUploadPoint(increment: increasing))
        return uploadPoints
    }
    func groupPostLike(post: GroupPost) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        uploadPoints.append(PostLikesModel(postID: postID).toMultiUploadPoint(with: true))
        uploadPoints.append(LikesModel(postID: postID).toMultiUploadPoint(with: true))
        uploadPoints.append(LikeCount(postID: postID).toMultiUploadPoint(increment: true))
//        if let notification = NotificationModel.createNotification(type: .GroupLikedPost, to: post.posterID, postID: post.id, groupID: post.groupID)?.toFirebaseJSON() {
//            uploadPoints.append(notification)
//        }
        return uploadPoints
    }
    func postLike(post: PostModel) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        uploadPoints.append(PostLikesModel(postID: postID).toMultiUploadPoint(with: true))
        uploadPoints.append(LikesModel(postID: postID).toMultiUploadPoint(with: true))
        uploadPoints.append(LikeCount(postID: postID).toMultiUploadPoint(increment: true))
//        if let notification = NotificationModel.createNotification(type: .LikedPost, to: post.posterID, postID: post.id)?.toFirebaseJSON() {
//            uploadPoints.append(notification)
//        }
        return uploadPoints
    }
}
