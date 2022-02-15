//
//  FollowersModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Struct Followers Model
struct FollowersModel: FirebaseInstance {
    var id: String
    var internalPath: String {
        return "Followers/\(id)"
    }
}

// MARK: - Following Model
struct FollowingModel: FirebaseInstance {
    var id: String
    var internalPath: String {
        return "Following/\(id)"
    }
}

// MARK: - Check Following Model
struct CheckFollowingModel: FirebaseInstance {
    var id: String
    var internalPath: String {
        return "Following/\(UserDefaults.currentUser.uid)/\(id)"
    }
}
