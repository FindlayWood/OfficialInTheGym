//
//  LikeSearchModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Like Search Model
/// Model to search if current user has liked given post
struct LikeSearchModel {
    
    /// The id of the given post
    var postID: String
}
extension LikeSearchModel: FirebaseInstance {
    var internalPath: String {
        return "PostLikes/\(postID)/\(UserDefaults.currentUser.uid)"
    }
}

struct LikedCommentSearchModel {
    var commentID: String
}
extension LikedCommentSearchModel: FirebaseInstance {
    var internalPath: String {
        "LikedComments/\(UserDefaults.currentUser.uid)/\(commentID)"
    }
}
