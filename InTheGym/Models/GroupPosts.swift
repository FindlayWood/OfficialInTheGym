//
//  GroupPosts.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Group Posts Model
/// Model to fetch all posts belonging to specified group

struct GroupPostsModel: Codable {
    var groupID: String
}

/// Conforming to FirebaseInstacne to provide path to return groupPosts
extension GroupPostsModel: FirebaseInstance {
    var internalPath: String {
        return "GroupPosts/\(groupID)"
    }
}

struct GroupModel: Assignable, Codable, Hashable {
    var uid: String
    var description: String
    var leader: String
    var title: String
    var username: String
}
extension GroupModel: FirebaseInstance {
    var internalPath: String {
        return "Groups/\(uid)"
    }
}
