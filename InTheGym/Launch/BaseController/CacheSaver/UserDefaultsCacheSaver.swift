//
//  UserDefaultsCacheSaver.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserDefaultsCacheUserSaver: CacheUserSaver {
    
    /// save given user model to cache - UserDefaults
    /// - Parameter user: optional user model to save - nil to remove
    func save(_ user: Users) {
        UserDefaults.currentUser = user
    }
}
