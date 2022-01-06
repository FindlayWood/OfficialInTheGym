//
//  CommentSectionItems.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation


enum CommentSectionSections: Hashable {
    case Post
    case comments
}

enum CommentItems: Hashable {
    case mainPost(post)
    case comment(Comment)
}

enum GroupCommentItems: Hashable {
    case mainPost(GroupPost)
    case comment(Comment)
}
