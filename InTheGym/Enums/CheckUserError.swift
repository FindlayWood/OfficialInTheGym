//
//  CheckUserError.swift
//  InTheGym
//
//  Created by Findlay-Personal on 16/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Firebase
import FirebaseAuth
import Foundation

enum checkingForUserError: Error {
    case noUser
    case reloadError
    case notVerified(User)
}
