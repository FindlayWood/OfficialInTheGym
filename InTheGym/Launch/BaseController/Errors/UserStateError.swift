//
//  UserStateError.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

enum UserStateError: Error {
    case noUser
    case notVerified
    case noAccount(email: String, uid: String)
}
