//
//  PostInteractionEndpoint.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

enum LikePostEndpoint: MultipleDatabaseEndpoint {
    case likePost(post: PostModel)
    case likeGroupPost(post: PostModel, groupID: String)

    var paths: [String : Any] {
        switch self {
        case .likePost(let post):
            return ["Likes/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(post.id)": true,
                    "PostLikes/\(post.id)/\(FirebaseAuthManager.currentlyLoggedInUser.uid)": true,
                    "Posts/\(post.id)/likeCount": ServerValue.increment(1)]
        case .likeGroupPost(let post, let groupID):
            return ["Likes/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(post.id)": true,
                    "PostLikes/\(post.id)/\(FirebaseAuthManager.currentlyLoggedInUser.uid)": true,
                    "GroupPosts/\(groupID)/\(post.id)/likeCount": ServerValue.increment(1)]
        }
    }
}


