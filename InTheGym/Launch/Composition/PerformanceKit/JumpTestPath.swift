//
//  JumpTestPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

/// Where an athlete's jump-test sessions live: `Users/{uid}/JumpTests/{id}`,
/// one collection for every jump test, told apart by `kind`. One collection so
/// the weekly fatigue check, and later a coach's summary, read every test from
/// one place. **The one definition of the path**; the loader and the writer
/// derive theirs from here.
///
/// Rules are not in this repository. Reads and writes here need the `Users`
/// rules to allow the owner this subcollection.
enum JumpTestPath {

    static func sessions(of userId: String) -> String {
        "Users/\(userId)/JumpTests"
    }
}
