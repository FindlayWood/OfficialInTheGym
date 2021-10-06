//
//  PostTypes.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

enum PostTypes: String, Codable {
    case post = "post"
    case attachedWorkout = "attachedWorkout"
    case attachedPhoto = "attachedPhoto"
    case attachedClip = "attachedClip"
}

class post: Codable, AutoIDable {
    //var postID: String
    var username: String
    var posterID: String
    var time: TimeInterval
    var text: String
    //var postType: PostTypes
    var attachedWorkout: attachedWorkout?
    var attachedPhoto: attachedPhoto?
    var attachedClip: attachedClip?
    var likeCount: Int
    var replyCount: Int
    var isPrivate: Bool
    var id : String 
}

struct attachedClip: Codable {
    var storageURL: String
    var storageID: String
}

struct attachedWorkout: Codable {
    var title: String
    var createdBy: String
    var exerciseCount: Int
    var storageID: String
    var postedWorkoutType: postedWorkoutType
    
}

struct attachedPhoto: Codable {
    var storageID: String
    var storageURL: String
}

enum postedWorkoutType: String, Codable {
    case saved = "saved"
    case completed = "completed"
}
