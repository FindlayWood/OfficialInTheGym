//
//  DiscoverBlockPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The one definition of where a user's blocks live.
enum DiscoverBlockPath {
    static func blockedUsers(of userId: String) -> String {
        "Users/\(userId)/BlockedUsers"
    }
}
