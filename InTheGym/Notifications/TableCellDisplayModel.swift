//
//  TableCellDisplayModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class NotificationTableViewModel{
    
    var from:Users?
    var postID:String?
    var message:String?
    var time:TimeInterval?
    var type:NotificationType?
    var groupID:String?
    
    init?(snapshot:DataSnapshot) {
        guard let snap = snapshot.value as? [String:AnyObject] else{
            return
        }
        self.time = snap["time"] as? TimeInterval
        
        switch snap["type"] as! String{
        case "LikedPost":
            self.message = "liked your post."
            self.postID = snap["postID"] as? String
            self.type = .LikedPost
        case "Reply":
            self.message = "replied to your post."
            self.postID = snap["postID"] as? String
            self.type = .Reply
        case "Followed":
            self.message = "started following you."
            self.postID = nil
            self.type = .Followed
        case "groupReply":
            self.message = "replied to your group post."
            self.postID = snap["postID"] as? String
            self.groupID = snap["groupID"] as? String
            self.type = .groupReply
        case "groupLikedPost":
            self.message = "liked your group post."
            self.postID = snap["postID"] as? String
            self.groupID = snap["groupID"] as? String
            self.type = .groupLikedPost
        default:
            break
        }
    }
    
    
    
    
}
