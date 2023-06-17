//
//  UserCacheServiceAdapter.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserCacheServiceAdapter: UserLoader {
    
    func loadUser() async -> Result<Users,UserStateError> {
        if UserDefaults.currentUser == Users.nilUser {
            return .failure(.noUser)
        } else {
            return .success(UserDefaults.currentUser)
        }
    }
}
