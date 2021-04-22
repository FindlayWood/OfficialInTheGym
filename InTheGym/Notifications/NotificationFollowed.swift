//
//  NotificationFollowed.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct NotificationFollowed: NotificationDelegate {

    var fromUserID:String?
    var toUserID:String?
    var type:NotificationType?
    var postID:String?
    var seen :Bool?
    
    init(from:String,to:String){
        self.fromUserID = from
        self.toUserID = to
        self.type = .Followed
        self.postID = nil
        self.seen = false
    }

    func toObject() -> [String:AnyObject]{
        let object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!,
                      "type":"Followed",
                      "time":ServerValue.timestamp(),
                      "seen":false] as [String:AnyObject]
        return object
    }

}
