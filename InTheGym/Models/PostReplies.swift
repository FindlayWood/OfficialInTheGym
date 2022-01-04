//
//  PostReplies.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - PostReplies Model
/// Model that can retreive all replies to a post
/// The path will point to PostReplies/PostID and return an array of type Comment

struct PostReplies {
    var postID: String
}

/// Conforming to FirebaseInstance to retreive all replies to a specific post
extension PostReplies: FirebaseInstance {
    var internalPath: String {
        return "PostReplies/\(postID)"
    }
}
