//
//  CreateNewPostModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Create New Post Model
struct CreateNewPostModel: Encodable {
    var id: String = ""
    var username: String = ""
    var posterID: String = ""
    var time: TimeInterval = 0
    var text: String = ""
    var likeCount: Int = 0
    var replyCount: Int = 0
    var attachedPhoto: attachedPhoto?
    var attachedClip: attachedClip?
    var attachedWorkout: attachedWorkout?
    var isPrivate: Bool = false
}

// MARK: - Postable
/// Type that must conform to FirebaseTimeOrderedModel
/// Type that has variables that can change within a created post
protocol Postable: FirebaseTimeOrderedModel {
    
    /// text can be entered and changed by user
    var text: String { get set }
    
    /// isPrivate variable can be changed by user
    var isPrivate: Bool { get set }
    
    /// time variable is set when the user taps post
    var time: TimeInterval { get set }
    
    /// user may choose to attach a workout
    var workoutID: String? { get set }
    
    /// user may choose to attach saved workout
    var savedWorkoutID: String? { get set }
    
}
