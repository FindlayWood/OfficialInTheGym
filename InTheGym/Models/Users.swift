//
//  Users.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import Foundation

/// users object containing all user profile info
struct Users: Codable, Hashable, Assignable {
    var admin: Bool
    var email: String
    var username: String
    var firstName: String
    var lastName: String
    var numberOfCompletes: Int?
    var uid: String
    var profilePhotoURL: String?
    var profileBio: String?
    
    var id: String {
        return uid
    }
    
    static func == (lhs: Users, rhs: Users) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
/// Allows a user model to be decoded from Firebase
extension Users: FirebaseResource {
    static var path: String {
        return "users"
    }
    var internalPath: String {
        return "users/\(uid)"
    }
}

// MARK: - User Search Model
/// allows a user to be returened from just an id
struct UserSearchModel {
    var uid: String
}
extension UserSearchModel: FirebaseInstance {
    var internalPath: String {
        return "users/\(uid)"
    }
}
