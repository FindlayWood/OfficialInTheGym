//
//  Posts.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/12/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//
// post model

import Foundation


struct PostModel: Codable, Hashable, DisplayablePost, Postable {
    var id: String = UUID().uuidString
    var username: String
    var posterID: String
    var time: TimeInterval
    var text: String
//    var attachedWorkout: attachedWorkout?
//    var attachedPhoto: attachedPhoto?
//    var attachedClip: attachedClip?
    var workoutID: String?
    var savedWorkoutID: String?
    var likeCount: Int
    var replyCount: Int
    var isPrivate: Bool
    
    init() {
        self.username = UserDefaults.currentUser.username
        self.posterID = UserDefaults.currentUser.uid
        self.time = Date().timeIntervalSince1970
        self.text = ""
        self.likeCount = 0
        self.replyCount = 0
        self.isPrivate = false
    }
    init(workoutID: String) {
        self.username = UserDefaults.currentUser.username
        self.posterID = UserDefaults.currentUser.uid
        self.time = Date().timeIntervalSince1970
        self.workoutID = workoutID
        self.text = ""
        self.likeCount = 0
        self.replyCount = 0
        self.isPrivate = false
    }
    
    
//    static func == (lhs: PostModel, rhs: PostModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
}
extension PostModel: FirebaseModel {
    static var path: String {
        return "Posts"
    }
}

extension PostModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Posts"
    }
}
