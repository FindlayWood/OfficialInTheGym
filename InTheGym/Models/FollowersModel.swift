//
//  FollowersModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Struct Followers Model
/// Model to check follower count
struct FollowersModel: FirebaseInstance {
    var id: String
    var internalPath: String {
        return "Followers/\(id)"
    }
}

// MARK: - Following Model
/// Model to check following count
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

// MARK: - Follow Model
/// Model to use when a user follows another user
struct FollowModel {
    /// The id of the user to follow
    var id: String
    
    func getUploadPoints() -> [FirebaseMultiUploadDataPoint] {
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(FirebaseMultiUploadDataPoint(value: true, path: followingPath))
        points.append(FirebaseMultiUploadDataPoint(value: true, path: followersPath))
        return points
    }
}
extension FollowModel {
    var followingPath: String {
        return "Following/\(UserDefaults.currentUser.uid)/\(id)"
    }
    var followersPath: String {
        return "Followers/\(id)/\(UserDefaults.currentUser.uid)"
    }
}
