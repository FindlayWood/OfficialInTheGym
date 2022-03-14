//
//  NotificationModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation


// MARK: - Notification Model
struct NotificationModel: Hashable {
    var id: String
    var fromUserID: String
    var toUserID: String
    var postID: String?
    var groupID: String?
    var workoutID: String?
    var savedWorkoutID: String?
    var time: TimeInterval
    var seen: Bool
    var type: NotificationType
    
    init(to: String, postID: String? = nil, groupID: String? = nil, workoutID: String? = nil, savedWorkoutID: String? = nil, type: NotificationType) {
        self.id = UUID().uuidString
        self.fromUserID = UserDefaults.currentUser.uid
        self.toUserID = to
        self.postID = postID
        self.groupID = groupID
        self.workoutID = workoutID
        self.savedWorkoutID = savedWorkoutID
        self.time = Date().timeIntervalSince1970
        self.seen = false
        self.type = type
    }
}
extension NotificationModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Notifications/\(toUserID)"
    }
}
extension NotificationModel: FirebaseModel {
    static var path: String {
        return "Notifications/\(UserDefaults.currentUser.uid)"
    }
}
