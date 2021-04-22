//
//  NotificationNewWorkout.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class NotificationNewWorkout : NotificationDelegate {
    var fromUserID: String?
    var toUserID: String?
    var type: NotificationType?
    var postID: String?
    var seen: Bool?
    func toObject() -> [String : AnyObject] {
        let object = ["fromUserID":fromUserID!,
                      "toUserID":toUserID!,
                      "type":"NewWorkout",
                      "time":ServerValue.timestamp(),
                      "seen":false] as [String:AnyObject]
        return object
    }
    init(from:String, to:String, workoutID:String) {
        self.fromUserID = from
        self.toUserID = to
        self.type = .NewWorkout
        self.seen = false
    }
    
    
}
