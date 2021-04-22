//
//  NotificationRequests.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct NotificationNewRequest : NotificationDelegate {
    var fromUserID: String?
    var toUserID: String?
    var type: NotificationType?
    var postID: String?
    var seen: Bool?
    func toObject() -> [String : AnyObject] {
        let object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!,
                      "type":"NewRequest",
                      "time":ServerValue.timestamp(),
                      "seen":false] as [String:AnyObject]
        return object
    }
    init(from:String, to:String){
        self.fromUserID = from
        self.toUserID = to
        self.seen = false
        self.type = .NewRequest
    }
    
    
}
