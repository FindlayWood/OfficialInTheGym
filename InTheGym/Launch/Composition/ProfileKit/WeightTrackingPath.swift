//
//  WeightTrackingPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// The one definition of where a user's weight log lives. `createAccount`
/// seeds the same collection with the signup weight, and the
/// `syncLatestWeight` function watches it. **The name must match both.**
enum WeightTrackingPath {
    static func entries(of userId: String) -> String {
        "Users/\(userId)/WeightTracking"
    }

    static func entry(_ entryId: String, of userId: String) -> String {
        "\(entries(of: userId))/\(entryId)"
    }
}
