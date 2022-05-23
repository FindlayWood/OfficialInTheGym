//
//  PostTypes.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

enum PostTypes {
    case post(PostModel)
    case groupPost(GroupPost)
}

protocol DisplayablePost {
    var username: String { get }
    var posterID: String { get }
    var time: TimeInterval { get }
    var text: String { get }
//    var attachedWorkout: attachedWorkout? { get }
//    var attachedPhoto: attachedPhoto? { get }
//    var attachedClip: attachedClip? { get }
    var workoutID: String? { get }
    var savedWorkoutID: String? { get }
    var likeCount: Int { get set }
    var replyCount: Int { get set }
    var isPrivate: Bool { get }
    var id: String { get }
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
