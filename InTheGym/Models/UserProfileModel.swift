//
//  UserProfileModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - User Profile Model
class UserProfileModel: Hashable {
    static func == (lhs: UserProfileModel, rhs: UserProfileModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String = UUID().uuidString
    var user: Users
    var followers: Int
    var following: Int
    
    init(user: Users, followers: Int = 0, following: Int = 0) {
        self.user = user
        self.followers = followers
        self.following = following
    }
}
