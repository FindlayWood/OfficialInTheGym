//
//  FirestoreUsernameReserver.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import AccountCreationKit
import Foundation

struct FirestoreUsernameReserver: UsernameReserver {

    var firestoreService: FirestoreService = FirestoreManager.shared

    func reserveUsername(_ username: String, for uid: String) async throws {
        let model = UsernameModel(username: username, uid: uid)
        try await firestoreService.upload(data: model, at: "Usernames/\(username)")
    }
}
