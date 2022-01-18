//
//  NotificationModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct NotificationModel: Codable, Hashable {
    
    var id: String
    var from: String
    var to: String
    var seen: Bool
    var type: NotificationType
    var time: TimeInterval
    var postID: String?
    var groupID: String?
    
    init(to: String, type: NotificationType, postID: String? = nil, groupID: String? = nil) {
        self.to = to
        self.type = type
        self.postID = postID
        self.groupID = groupID
        self.id = UUID().uuidString
        self.from = FirebaseAuthManager.currentlyLoggedInUser.uid
        self.seen = false
        self.time = Date().timeIntervalSince1970
    }
    
    static func createNotification(type: NotificationType, to: String, postID: String? = nil, groupID: String? = nil) -> NotificationModel? {
        if to == FirebaseAuthManager.currentlyLoggedInUser.uid { return nil }
        else { return .init(to: to, type: type, postID: postID, groupID: groupID) }
    }
}
extension NotificationModel: FirebaseResource {
    static var path: String {
        return "Notifications/\(FirebaseAuthManager.currentlyLoggedInUser.uid)"
    }
    var internalPath: String {
        return "Notifications/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(id)"
    }
}
