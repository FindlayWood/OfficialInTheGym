//
//  FollowPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// The one definition of a follow document's location:
/// `Follows/{followerId}_{followeeId}`. **It must match the functions'
/// `followId()` and the `Follows` create rule**, which checks the id is exactly
/// this. That check is what makes following someone twice impossible.
enum FollowPath {
    static let collection = "Follows"

    static func document(follower: String, followee: String) -> String {
        "\(collection)/\(follower)_\(followee)"
    }
}
