//
//  TransformPost.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class TransformPost: NSObject {
    
    static func toPost(from data:[String:AnyObject]) -> Post{
        var post = Post()
        post.postID = data["postID"] as? String
        post.posterID = data["posterID"] as? String
        post.username = data["username"] as? String
        post.time = data["time"] as? TimeInterval
        post.message = data["message"] as? String
        post.isPrivate = data["isPrivate"] as? Bool
        post.workoutID = data["workoutID"] as? String
        
        // convery string to post type
        let type = TransformPost.stringToActivityType(with: data["type"] as! String)
        post.postType = type as postType
        
        
        // convert [string:anyobject] to workout
        if type == .completedWorkout || type == .createdWorkout{
            let workoutData = TransformWorkout.toWorkoutType(from: data["exerciseData"] as? [String:AnyObject] ?? [:])
            post.workoutData = workoutData
        }
        
        
        return post
        
        
        
    }
    
    static func toDictionary(from post:Post) -> [String:AnyObject]{
        
        var data = ["postID":post.postID!,
                    "posterID":post.posterID!,
                    "time":post.time!,
                    "username":post.username!,
                    "isPrivate":post.isPrivate] as [String:AnyObject]
        
        switch post.postType {
        case .writtenPost:
            data["message"] = post.message as AnyObject
            data["type"] = "post" as AnyObject
            return data
        case .createdWorkout:
            data["workoutID"] = post.workoutID as AnyObject
            data["exerciseData"] = post.workoutData as AnyObject
            data["type"] = "createdWorkout" as AnyObject
            return data
        case .completedWorkout:
            data["workoutID"] = post.workoutID as AnyObject
            data["exerciseData"] = post.workoutData as AnyObject
            data["type"] = "workout" as AnyObject
            return data
        default:
            // need specific type here
            let type = TransformPost.activityTypeToString(of: post.postType)
            data["type"] = type as AnyObject
            return data
        }
    }
    
    static func activityTypeToString(of type:postType) -> String{
        switch type {
        case postType.CompletedWorkout:
            return "Completed Workout"
        case postType.completedWorkout:
            return "workout"
        case postType.createdWorkout:
            return "createdWorkout"
        case postType.writtenPost:
            return "post"
        case postType.SetWorkout:
            return "Set Workout"
        case postType.UpdatePBs:
            return "Update PBs"
        case postType.AccountCreated:
            return "Account Created"
        case postType.NewGroup:
            return "New Group"
        case postType.NewPlayer:
            return "New Player"
        case postType.NewCoach:
            return "New Coach"
        case postType.RequestSent:
            return "Request Sent"
        case postType.RequestDeclined:
            return "Request Declined"
        default:
            return "invalid"
        
        
        }
    }
    
    static func stringToActivityType(with string:String) -> postType{
        switch string {
        case "Completed Workout":
            return postType.CompletedWorkout
        case "workout":
            return postType.completedWorkout
        case "createdWorkout":
            return postType.createdWorkout
        case "post":
            return postType.writtenPost
        case "Set Workout":
            return postType.SetWorkout
        case "Update PBs":
            return postType.UpdatePBs
        case "Account Created":
            return postType.AccountCreated
        case "New Group":
            return postType.NewGroup
        case "New Player":
            return postType.NewPlayer
        case "New Coach":
            return postType.NewCoach
        case "Request Sent":
            return postType.RequestSent
        case "Request Declined":
            return postType.RequestDeclined
        default:
            return postType.invalidPost
        }
    }
    
    
}
