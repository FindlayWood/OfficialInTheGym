//
//  NotificationReplied.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct NotificationReplied: NotificationDelegate {
    
    var fromUserID:String?
    var toUserID:String?
    var type:NotificationType?
    var postID:String?
    var seen: Bool?
    
    init(from:String,to:String,postID:String){
        self.fromUserID = from
        self.toUserID = to
        self.postID = postID
        self.type = .Reply
        self.seen = false
    }

    func toObject() -> [String:AnyObject]{
        let object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!,
                      "postID":postID!,
                      "type":"Reply",
                      "time":ServerValue.timestamp(),
                      "seen":false] as [String:AnyObject]
        return object
    }

}

struct NotificationGroupReplied: GroupNotificationDelegate {
    
    var groupID: String?
    var fromUserID:String?
    var toUserID:String?
    var type:NotificationType?
    var postID:String?
    var seen: Bool?
    
    init(from:String,to:String,postID:String, groupID:String){
        self.fromUserID = from
        self.toUserID = to
        self.postID = postID
        self.type = .GroupReply
        self.groupID = groupID
        self.seen = false
    }

    func toObject() -> [String:AnyObject]{
        let object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!,
                      "postID":postID!,
                      "type":"groupReply",
                      "groupID":groupID!,
                      "time":ServerValue.timestamp(),
                      "seen": false] as [String:AnyObject]
        return object
    }

}
