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
        return "PostLikes/\(postID)/\(UserDefaults.currentUser.uid)"
    }
}

struct CommentLikesModel {
    var commentID: String
    
    func toMultiUploadPoint(with value: Bool) -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: value, path: internalPath)
    }
}
extension CommentLikesModel {
    var internalPath: String {
        "CommentLikes/\(commentID)/\(UserDefaults.currentUser.uid)"
    }
}
struct LikedCommentsModel {
    var commentID: String
    
    func toMultiUploadPoint(with value: Bool) -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: value, path: internalPath)
    }
}
extension LikedCommentsModel {
    var internalPath: String {
        "LikedComments/\(UserDefaults.currentUser.uid)/\(commentID)"
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
        return "Likes/\(UserDefaults.currentUser.uid)/\(postID)"
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

    func postLike(post: PostModel) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        uploadPoints.append(PostLikesModel(postID: postID).toMultiUploadPoint(with: true))
        uploadPoints.append(LikesModel(postID: postID).toMultiUploadPoint(with: true))
        uploadPoints.append(LikeCount(postID: postID).toMultiUploadPoint(increment: true))
        return uploadPoints
    }
    
    func commentLike(comment: Comment) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        uploadPoints.append(CommentLikesModel(commentID: comment.id).toMultiUploadPoint(with: true))
        uploadPoints.append(LikedCommentsModel(commentID: comment.id).toMultiUploadPoint(with: true))
        return uploadPoints
    }
}
