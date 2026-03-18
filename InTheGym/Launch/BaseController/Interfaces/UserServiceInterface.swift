//
//  UserService.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Load Service
protocol UserLoader {
    func loadUser() async -> Result<Users,UserStateError>
}

extension UserLoader {
    func fallback(_ fallback: UserLoader) -> UserLoader {
        UserServiceWithFallback(primary: self, fallback: fallback)
    }
}

// MARK: - Cache Saver
protocol CacheUserSaver {
    func save(_ user: Users)
}
