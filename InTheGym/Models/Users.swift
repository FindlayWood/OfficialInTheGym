//
//  Users.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Users Model
/// users object containing all user profile info
struct Users: Codable, Hashable, Assignable {
    var admin: Bool
    var email: String
    var username: String
    var firstName: String
    var lastName: String
    var premiumAccount: Bool?
    var numberOfCompletes: Int?
    var uid: String
    var profilePhotoURL: String?
    var profileBio: String?
    var accountCreated: TimeInterval?
    
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

// MARK: - Nil User
extension Users {
    static let nilUser = Users(admin: false, email: "", username: "", firstName: "", lastName: "", uid: "")
}


// MARK: - Username Search Model
struct UsernameSearchModel {
    var equalTo: String
}
extension UsernameSearchModel: FirebaseQueryModel {
    var orderedBy: String {
        return "username"
    }
    var internalPath: String {
        return "users"
    }
}

// MARK: - Coach Request Model
struct CoachRequestUploadModel {
    var playerID: String
    var coachID: String
}
extension CoachRequestUploadModel: FirebaseInstance {
    var internalPath: String {
        return "CoachRequests/\(coachID)/\(playerID)"
    }
}

// MARK: - Player Request Model
/// Model only used by coaches to send requests
struct PlayerRequestUploadModel {
    var playerID: String
    var coachID: String
}
extension PlayerRequestUploadModel: FirebaseInstance {
    var internalPath: String {
        return "PlayerRequests/\(playerID)/\(coachID)"
    }
}

// MARK: - Coach PLayers Model
struct CoachPlayersModel {
    var coachID: String
    var playerID: String
    
    func getUploadPoint() -> FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: true, path: internalPath)
    }
}
extension CoachPlayersModel: FirebaseInstance {
    var internalPath: String {
        return "CoachPlayers/\(coachID)/\(playerID)"
    }
}

// MARK: - Player Coach Model
struct PlayerCoachModel {
    var playerID: String
    var coachID: String
    
    func getUploadPoint() -> FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: true, path: internalPath)
    }
}
extension PlayerCoachModel: FirebaseInstance {
    var internalPath: String {
        return "PlayerCoaches/\(playerID)/\(coachID)"
    }
}
