//
//  UserServiceWithFallback.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserServiceWithFallback: UserService {
    var primary: UserService
    var fallback: UserService
    
    func loadUser() async throws -> Users {
        do {
            let primary = try await primary.loadUser()
            return primary
        } catch {
            return try await fallback.loadUser()
        }
    }
}
