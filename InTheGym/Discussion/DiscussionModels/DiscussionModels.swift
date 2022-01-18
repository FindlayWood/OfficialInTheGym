//
//  DiscussionModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase


struct DiscussionPost:PostProtocol {
    var username: String?
    var time: TimeInterval?
    var message: String?
    var posterID: String?
    var postID: String?
    var isPrivate: Bool?
    var likeCount: Int?
    var replyCount: Int?
    
    init?(model:TimelinePostModel){
        self.username = model.username
        self.time = model.time
        self.message = model.message
        self.posterID = model.posterID
        self.postID = model.postID
        self.isPrivate = model.isPrivate
        self.likeCount = model.likeCount
        self.replyCount = model.replyCount
    }
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return
        }
        self.username = snap["username"] as? String
        self.posterID = snap["posterID"] as? String
        self.postID = snapshot.key
        self.message = snap["message"] as? String
        self.likeCount = snap["likeCount"] as? Int
        self.replyCount = snap["replyCount"] as? Int
        self.isPrivate = snap["isPrivate"] as? Bool
        self.time = snap["time"] as? TimeInterval
    }
    
    func toObject() -> [String : AnyObject] {
        return [:]
    }
    
    
    
}

struct DiscussionCreatedWorkout:PostProtocol{
    var username: String?
    var time: TimeInterval?
    var createdWorkout:discoverWorkout?
    var posterID: String?
    var postID: String?
    var isPrivate: Bool?
    var likeCount: Int?
    var replyCount: Int?
    
    init?(model:TimelineCreatedWorkoutModel){
        self.username = model.username
        self.time = model.time
        self.createdWorkout = model.createdWorkout
        self.posterID = model.posterID
        self.postID = model.postID
        self.isPrivate = model.isPrivate
        self.likeCount = model.likeCount
        self.replyCount = model.replyCount
    }
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return
        }
        self.username = snap["username"] as? String
        self.posterID = snap["posterID"] as? String
        self.postID = snapshot.key
        self.likeCount = snap["likeCount"] as? Int
        self.replyCount = snap["replyCount"] as? Int
        self.isPrivate = snap["isPrivate"] as? Bool
        self.time = snap["time"] as? TimeInterval
        self.createdWorkout = discoverWorkout(object: snap["exerciseData"] as! [String : AnyObject])

    }
    
    func toObject() -> [String : AnyObject] {
        return [:]
    }
    
    
    
}

struct DiscussionCompletedWorkout:PostProtocol{
    var username: String?
    var time: TimeInterval?
    var completedWorkout:discoverWorkout?
    var posterID: String?
    var postID: String?
    var isPrivate: Bool?
    var likeCount: Int?
    var replyCount: Int?
    
    init?(model:TimelineCompletedWorkoutModel){
        self.username = model.username
        self.time = model.time
        self.completedWorkout = model.createdWorkout
        self.posterID = model.posterID
        self.postID = model.postID
        self.isPrivate = model.isPrivate
        self.likeCount = model.likeCount
        self.replyCount = model.replyCount
    }
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return
        }
        self.username = snap["username"] as? String
        self.posterID = snap["posterID"] as? String
        self.postID = snapshot.key
        self.likeCount = snap["likeCount"] as? Int
        self.replyCount = snap["replyCount"] as? Int
        self.isPrivate = snap["isPrivate"] as? Bool
        self.time = snap["time"] as? TimeInterval
        self.completedWorkout = discoverWorkout(object: snap["exerciseData"] as! [String : AnyObject])
    }
    
    func toObject() -> [String : AnyObject] {
        return [:]
    }
    
    
}

struct DiscussionReply:PostProtocol{
    var username: String?
    var time: TimeInterval?
    var message: String?
    var likeCount:Int?
    var replyCount:Int?
    var posterID: String?
    var postID: String?
    var isPrivate: Bool?
    
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return
        }
        self.username = snap["username"] as? String
        self.time = snap["time"] as? TimeInterval
        self.message = snap["message"] as? String
        self.posterID = snap["posterID"] as? String
        self.postID = snapshot.key
        self.isPrivate = false
    }
    
    func toObject() -> [String:AnyObject] {
        return [:]
    }
}

struct DiscussionReplyPlusWorkout: PostProtocol {
    var username: String?
    var time: TimeInterval?
    var message: String?
    var attachedWorkoutSavedID: String?
    var attachedWorkoutTitle: String?
    var attachedWorkoutCreator: String?
    var attachedWorkoutCreatorID: String?
    var attachedWorkoutExerciseCount: Int?
    var posterID: String?
    var postID: String?
    var likeCount: Int?
    var replyCount: Int?
    var isPrivate: Bool?

    init?(snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return
        }
        self.username = snap["username"] as? String
        self.time = snap["time"] as? TimeInterval
        self.message = snap["message"] as? String
        self.attachedWorkoutSavedID = snap["attachedWorkoutSavedID"] as? String
        self.attachedWorkoutTitle = snap["attachedWorkoutTitle"] as? String
        self.attachedWorkoutCreator = snap["attachedWorkoutCreator"] as? String
        self.attachedWorkoutCreatorID = snap["attachedWorkoutCreatorID"] as? String
        self.attachedWorkoutExerciseCount = snap["attachedWorkoutExerciseCount"] as? Int
        self.posterID = snap["posterID"] as? String
        self.postID = snapshot.key
        self.isPrivate = false
    }
    
    func toObject() -> [String : AnyObject] {
        return [:]
    }
}

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
