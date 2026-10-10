//
//  VerticalJumpPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

/// Where a user's jumps live in Firestore. The one definition of these paths:
/// both loaders and both writers derive theirs from here.
///
/// `VerticalJump/{uid}` holds the best jump and `VerticalJump/{uid}/Results/{id}`
/// holds every saved jump.
enum VerticalJumpPath {

    static func best(of userId: String) -> String {
        "VerticalJump/\(userId)"
    }

    static func results(of userId: String) -> String {
        "VerticalJump/\(userId)/Results"
    }
}
