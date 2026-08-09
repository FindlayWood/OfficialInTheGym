//
//  UsernameModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The document stored at `Usernames/{username}` — the claim that reserves a name.
///
/// This is a Firestore shape, so it lives here rather than in `AccountCreationKit`: the kit asks
/// whether a name is free and asks for it to be reserved, and does not know how either is stored.
struct UsernameModel: Codable {
    var username: String
    var uid: String
    var dateTaken: Date = .now
}
