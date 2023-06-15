//
//  UserCacheServiceAdapter.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserCacheServiceAdapter: UserLoader {
    
    func loadUser() async throws -> Users {
        if UserDefaults.currentUser == Users.nilUser {
            throw NSError(domain: "No user in UserDefaults", code: 0)
        } else {
            return UserDefaults.currentUser
        }
    }
}
