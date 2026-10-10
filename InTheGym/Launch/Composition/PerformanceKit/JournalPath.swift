//
//  JournalPath.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

/// Where a user's journal lives in Firestore. The one definition of these
/// paths: the loader and both writers derive theirs from here.
///
/// `Journal/{uid}` holds the latest entry and `Journal/{uid}/Entries/{id}` holds
/// every entry. Nothing in the app reads the latest-entry document. It is
/// still written, because it always has been and something outside this
/// repository may read it.
enum JournalPath {

    static func latest(of userId: String) -> String {
        "Journal/\(userId)"
    }

    static func entries(of userId: String) -> String {
        "Journal/\(userId)/Entries"
    }
}
