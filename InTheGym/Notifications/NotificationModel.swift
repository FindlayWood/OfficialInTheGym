//
//  NotificationModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

struct NotificationModel {
    var fromUserID:String?
    var toUserID:String?
    var type:NotificationType?
    
    init?(from:String, to:String, type:NotificationType){
        self.fromUserID = from
        self.toUserID = to
        self.type = type
    }
    
    func toObject() -> [String:AnyObject]{
        var object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!] as [String:AnyObject]
        switch type {
        case .LikedPost:
            object["type"] = "LikedPost" as AnyObject
        case .Followed:
            object["type"] = "Followed" as AnyObject
        case .ReplyToPost:
            object["type"] = "ReplyToPost" as AnyObject
        case .none:
            return object
        }
        
        return object
    }
    
}

enum NotificationType{
    case LikedPost
    case Followed
    case ReplyToPost
}
