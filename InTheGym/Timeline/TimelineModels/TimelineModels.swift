//
//  TimelineModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class TimelinePostModel: PostProtocol {
    
    var profileImageURL:String?
    var username:String?
    var time:TimeInterval?
    var posterID:String?
    var postID:String?
    var message:String?
    var likeCount:Int?
    var replyCount:Int?
    var isPrivate:Bool?
    
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
    
    init?(object : [String:AnyObject]){
        self.username = object["username"] as? String
        self.posterID = object["posterID"] as? String
        self.time = object["time"] as? TimeInterval
        self.message = object["message"] as? String
        self.isPrivate = object["isPrivate"] as? Bool
        self.postID = object["postID"] as? String
    }
    
    func toObject() -> [String : AnyObject] {
        var object:[String:AnyObject] = [:]
        object = ["username":username!,
                      "time":time!,
                      "posterID":posterID!,
                      "postID":postID!,
                      "isPrivate":isPrivate!,
                      "message":message!] as [String:AnyObject]
        
        if let likes = likeCount{
            object["likeCount"] = likes as AnyObject
        }
        if let replies = replyCount{
            object["replyCount"] = replies as AnyObject
        }
        return object
    }
    
}

class TimelineCreatedWorkoutModel: PostProtocol {
    var profileImageURL:String?
    var username:String?
    var time:TimeInterval?
    var posterID:String?
    var postID:String?
    var createdWorkout:discoverWorkout?
    var likeCount:Int?
    var replyCount:Int?
    var isPrivate:Bool?
    
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
        var object:[String:AnyObject] = [:]
        object = ["username":username!,
                      "time":time!,
                      "posterID":posterID!,
                      "postID":postID!,
                      "isPrivate":isPrivate!,
                      "exerciseData":createdWorkout?.toObject() as Any] as [String:AnyObject]
        
        if let likes = likeCount{
            object["likeCount"] = likes as AnyObject
        }
        if let replies = replyCount{
            object["replyCount"] = replies as AnyObject
        }
        return object
    }
}

class TimelineCompletedWorkoutModel: PostProtocol {
    var profileImageURL:String?
    var username:String?
    var time:TimeInterval?
    var posterID:String?
    var postID:String?
    var createdWorkout:discoverWorkout?
    var likeCount:Int?
    var replyCount:Int?
    var isPrivate:Bool?
    
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
        var object:[String:AnyObject] = [:]
        object = ["username":username!,
                      "time":time!,
                      "posterID":posterID!,
                      "postID":postID!,
                      "isPrivate":isPrivate!,
                      "exerciseData":createdWorkout?.toObject() as Any] as [String:AnyObject]
        
        if let likes = likeCount{
            object["likeCount"] = likes as AnyObject
        }
        if let replies = replyCount{
            object["replyCount"] = replies as AnyObject
        }
        
        return object
    }
}

class TimelineActivityModel: PostProtocol {
    var type:String?
    var username:String?
    var time:TimeInterval?
    var message:String?
    var likeCount:Int?
    var replyCount:Int?
    var posterID:String?
    var postID:String?
    var isPrivate:Bool?
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return
        }
        self.type = snap["type"] as? String
        self.message = snap["message"] as? String
        self.time = snap["time"] as? TimeInterval
        self.isPrivate = true
        self.posterID = snap["posterID"] as? String
        self.postID = snapshot.key
        
    }
    
    func toObject() -> [String : AnyObject] {
        var object:[String:AnyObject] = [:]
        object = ["username":username!,
                      "time":time!,
                      "posterID":posterID!,
                      "postID":postID!,
                      "message":message!,
                      "type":type!,
                      "isPrivate":isPrivate!] as [String:AnyObject]
        return object
    }
    
}

protocol PostProtocol{
    var username:String?{get}
    var time:TimeInterval?{get}
    var posterID:String?{get}
    var postID:String?{get}
    var likeCount:Int?{get set}
    var replyCount:Int?{get set}
    var isPrivate:Bool?{get set}
    func toObject() -> [String:AnyObject]
}
