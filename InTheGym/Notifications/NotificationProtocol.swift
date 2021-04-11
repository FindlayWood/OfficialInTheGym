//
//  NotificationProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol NotificationDelegate {
    var fromUserID:String? { get }
    var toUserID:String? {get}
    var type:NotificationType? {get}
    var postID:String?{get}
    func toObject() -> [String:AnyObject]
}

protocol GroupNotificationDelegate : NotificationDelegate {
    var groupID:String?{get}
}

enum NotificationType {
    case LikedPost
    case Reply
    case Followed
    case groupLikedPost
    case groupReply
}
