//
//  FirestoreUsernameAvailabilityChecker.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import AccountCreationKit
import Foundation

struct FirestoreUsernameAvailabilityChecker: UsernameAvailabilityChecker {

    var firestoreService: FirestoreService = FirestoreManager.shared

    func isUsernameAvailable(_ username: String) async throws -> Bool {
        // The optional is load-bearing. `FirestoreManager.read` goes through `getDocument(as:)`,
        // which decodes a missing document's `NSNull` into `nil` rather than throwing — so an
        // optional `T` distinguishes "no such document" (free) from a real failure. Asking for a
        // non-optional `UsernameModel` throws for every username that is actually available.
        let existing: UsernameModel? = try await firestoreService.read(at: "Usernames/\(username)")
        return existing == nil
    }
}
