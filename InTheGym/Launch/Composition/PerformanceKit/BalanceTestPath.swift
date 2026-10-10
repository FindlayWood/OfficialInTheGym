//
//  BalanceTestPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

/// Where an athlete's balance sessions live: `Users/{uid}/BalanceTests/{id}`.
/// A collection of its own rather than `JumpTests`, since a stand is not a
/// jump and shares none of its fields. **The one definition of the path.**
///
/// Rules are not in this repository. Reads and writes here need the `Users`
/// rules to allow the owner this subcollection.
enum BalanceTestPath {

    static func sessions(of userId: String) -> String {
        "Users/\(userId)/BalanceTests"
    }
}
