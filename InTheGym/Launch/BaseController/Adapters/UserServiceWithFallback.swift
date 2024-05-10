//
//  UserServiceWithFallback.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserServiceWithFallback: UserLoader {
    var primary: UserLoader
    var fallback: UserLoader
    
    func loadUser() async -> Result<Users,UserStateError> {
        do {
            let primary = try await primary.loadUser().get()
            return .success(primary)
        } catch {
            return await fallback.loadUser()
        }
    }
}
