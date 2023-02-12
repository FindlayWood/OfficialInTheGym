//
//  NotificationName+Extension.swift
//  InTheGym
//
//  Created by Findlay-Personal on 05/12/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

extension Notification {
    static let newPostFromCurrentUser = Notification.Name("newPostFromCurrentUser")
    static let deletedPost = Notification.Name("deletedPost")
}
