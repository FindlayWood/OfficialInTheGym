//
//  NotificationLikedPost.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct NotificationLikedPost: NotificationDelegate {
    
    var fromUserID:String?
    var toUserID:String?
    var type:NotificationType?
    var postID:String?
    
    init(from:String,to:String, postID:String){
        self.fromUserID = from
        self.toUserID = to
        self.postID = postID
        self.type = .LikedPost
    }

    func toObject() -> [String:AnyObject]{
        let object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!,
                      "postID":postID!,
                      "type":"LikedPost",
                      "time":ServerValue.timestamp()] as [String:AnyObject]
        return object
    }

}

struct NotificationGroupLikedPost : GroupNotificationDelegate {
    
    var groupID: String?
    var fromUserID:String?
    var toUserID:String?
    var type:NotificationType?
    var postID:String?
    
    init(from:String,to:String, postID:String, groupID:String){
        self.fromUserID = from
        self.toUserID = to
        self.postID = postID
        self.type = .groupLikedPost
        self.groupID = groupID
    }

    func toObject() -> [String:AnyObject]{
        let object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!,
                      "postID":postID!,
                      "type":"LikedPost",
                      "groupID":groupID!,
                      "time":ServerValue.timestamp()] as [String:AnyObject]
        return object
    }
}
