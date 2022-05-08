//
//  PostTypes.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

enum PostTypes {
    case post(post)
    case groupPost(GroupPost)
}

protocol DisplayablePost {
    var username: String { get }
    var posterID: String { get }
    var time: TimeInterval { get }
    var text: String { get }
    var attachedWorkout: attachedWorkout? { get }
    var attachedPhoto: attachedPhoto? { get }
    var attachedClip: attachedClip? { get }
    var workoutID: String? { get }
    var savedWorkoutID: String? { get }
    var likeCount: Int { get set }
    var replyCount: Int { get set }
    var isPrivate: Bool { get }
    var id: String { get }
}

class post: Codable, Hashable, AutoIDable, DisplayablePost, Postable {
    
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
    var likeCount: Int
    var replyCount: Int
    var isPrivate: Bool
    
    init() {
        self.id = UUID().uuidString
        self.username = UserDefaults.currentUser.username
        self.posterID = UserDefaults.currentUser.uid
        self.time = Date().timeIntervalSince1970
        self.text = ""
        self.likeCount = 0
        self.replyCount = 0
        self.isPrivate = false
    }
    init(workoutID: String) {
        self.id = UUID().uuidString
        self.username = UserDefaults.currentUser.username
        self.posterID = UserDefaults.currentUser.uid
        self.time = Date().timeIntervalSince1970
        self.workoutID = workoutID
        self.text = ""
        self.likeCount = 0
        self.replyCount = 0
        self.isPrivate = false
    }
    
    
    static func == (lhs: post, rhs: post) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension post: FirebaseModel {
    static var path: String {
        return "Posts"
    }
}

extension post: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Posts"
    }
}


class GroupPost: Codable, Hashable, AutoIDable, DisplayablePost, Postable {
    
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
