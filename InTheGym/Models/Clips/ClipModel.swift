//
//  ClipModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Clip Model
/// Model representing clip
/// Model conforms to FirebaseTimeOrderedModel
struct ClipModel: Codable, Hashable {
    var id: String
    var storageURL: String
    var exerciseName: String
    var time: TimeInterval
    var workoutID: String?
    var userID: String
    var isPrivate: Bool
    
    init(storageURL: String, exerciseName: String, workoutID: String?, isPrivate: Bool) {
        self.id = UUID().uuidString
        self.storageURL = storageURL
        self.exerciseName = exerciseName
        self.time = Date().timeIntervalSince1970
        self.workoutID = workoutID
        self.userID = UserDefaults.currentUser.uid
        self.isPrivate = isPrivate
    }
    
}
extension ClipModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Clips"
    }
}
extension ClipModel: FirebaseModel {
    static var path: String {
        return "Clips"
    }
}

//struct ClipModel: Codable, Hashable {
//    var id: String
//    var storageURL: String
//    var exerciseName: String
//    var time: TimeInterval
//    var workoutID: String?
//    var userID: String
//    var isPrivate: Bool
//}
//extension ClipModel: FirebaseResource {
//    var internalPath: String {
//        return "Clips/\(id)"
//    }
//
//    static var path: String {
//        return "Clips"
//    }
//}

struct KeyClipModel: Codable, Hashable {
    var clipKey: String
    var storageURL: String
}
extension KeyClipModel: FirebaseInstance {
    var internalPath: String {
        return "Clips/\(clipKey)"
    }
}
