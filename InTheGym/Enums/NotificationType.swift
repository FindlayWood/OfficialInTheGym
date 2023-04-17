//
//  NotificationType.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum NotificationType: String, Codable {
    case LikedPost = "LikedPost"
    case Reply = "Reply"
    case Followed = "Followed"
    case NewRequest = "NewRequest"
    case AcceptedRequest = "AcceptedRequest"
    case NewWorkout = "NewWorkout"
    
    var message: String {
        switch self {
        case .LikedPost:
            return "liked your post."
        case .Reply:
            return "replied to your post."
        case .Followed:
            return "started following you."
        case .NewRequest:
            return "sent you a coach request."
        case .AcceptedRequest:
            return "accepted your coach request."
        case .NewWorkout:
            return "assigned you a new workout."
        }
    }
}

enum CreateNotificationType {
    case acceptedRequest(sendTo: String)
    case likedPost(sendTo: String, postID: String)
    case sentRequest(sendTo: String)
}
