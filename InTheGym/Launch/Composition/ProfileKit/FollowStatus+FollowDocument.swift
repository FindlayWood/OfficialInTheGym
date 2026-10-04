//
//  FollowStatus+FollowDocument.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit

extension FollowStatus {

    /// A follow document's `status` field as a `FollowStatus`. No document, or a
    /// value this build does not know, is not following.
    init(followDocumentStatus status: String?) {
        switch status {
        case "active": self = .following
        case "pending": self = .requested
        default: self = .notFollowing
        }
    }
}
