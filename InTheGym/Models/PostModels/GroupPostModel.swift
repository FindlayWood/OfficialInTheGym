//
//  GroupPostModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct GroupPost: Codable, Hashable, AutoIDable, DisplayablePost, Postable {
    var id: String
    var username: String
    var posterID: String
    var time: TimeInterval
    var text: String
    var attachedWorkout: attachedWorkout?
    var attachedPhoto: attachedPhoto?
    var attachedClip: attachedClip?
    var workoutID: String?
    var savedWorkoutID: String?
    var taggedUsers: [String]?
    var likeCount: Int
    var replyCount: Int
    var isPrivate: Bool
    var groupID: String
    
    init(groupID: String) {
        self.id = UUID().uuidString
        self.username = UserDefaults.currentUser.username
        self.posterID = UserDefaults.currentUser.uid
        self.time = Date().timeIntervalSince1970
        self.text = ""
        self.likeCount = 0
        self.replyCount = 0
        self.isPrivate = false
        self.groupID = groupID
    }
    
    
    static func == (lhs: GroupPost, rhs: GroupPost) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension GroupPost: FirebaseModel {
    static var path: String {
        return "GroupPosts"
    }
}

extension GroupPost: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "GroupPosts/\(groupID)"
    }
}
