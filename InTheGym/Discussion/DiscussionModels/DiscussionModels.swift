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
