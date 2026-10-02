//
//  DiscoverLikeTarget+Firestore.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation

/// **The one definition of where a like lives.** One document per user, id'd
/// by the user, under whatever was liked — so liking twice is one document,
/// and "have I liked this" is one read.
extension DiscoverLikeTarget {

    func likePath(userId: String) -> String {
        switch self {
        case let .comment(commentId, subject):
            return "\(subject.commentPath(commentId))/Likes/\(userId)"
        case .clip(let id):
            return "\(DiscoverSubject.clip(id: id).documentPath)/Likes/\(userId)"
        }
    }
}
