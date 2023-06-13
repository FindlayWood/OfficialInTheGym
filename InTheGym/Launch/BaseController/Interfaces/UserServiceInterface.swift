//
//  UserService.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Load Service
protocol UserService {
    func loadUser() async throws -> Users
}

extension UserService {
    func fallback(_ fallback: UserService) -> UserService {
        UserServiceWithFallback(primary: self, fallback: fallback)
    }
}

// MARK: - Change Observer
protocol ObserveUserService {
    func observeChange(completion: @escaping (Result<Users,UserStateError>) -> Void)
}

// MARK: - Cache Saver
protocol CacheUserSaver {
    func save(_ user: Users)
}
