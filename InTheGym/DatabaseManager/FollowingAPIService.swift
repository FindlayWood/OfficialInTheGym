//
//  FollowingAPIService.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FollowingAPIService {
    static let shared = FollowingAPIService()
    
    private init(){}
    
    let followingCache = NSCache<NSString, NSNumber>()
    
    let baseRef = Database.database().reference()
    
    func get(followerID: String, completion: @escaping (Bool) -> Void) {
        if let following = followingCache.object(forKey: followerID as NSString) {
            if following == 1{
                completion(true)
            } else {
                completion(false)
            }
        } else {
            load(followerID: followerID, completion: completion)
        }
    }
    
    private func load(followerID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let path: String = "Following/\(userID)/\(followerID)"
        baseRef.child(path).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
                self.followingCache.setObject(1, forKey: followerID as NSString)
            } else {
                completion(false)
                self.followingCache.setObject(0, forKey: followerID as NSString)
            }
        }
    }
}
