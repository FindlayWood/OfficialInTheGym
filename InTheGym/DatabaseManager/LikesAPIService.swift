//
//  LikesAPIService.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class LikesAPIService {
    
    static let shared = LikesAPIService()
    
    private init(){}
    
    let LikedPostsCache = NSCache<NSString, NSNumber>()
    
    func check(postID: String, completion: @escaping (Bool) -> Void) {
        
        if let liked = LikedPostsCache.object(forKey: postID as NSString) {
            if liked == 1 {
                completion(true)
            } else {
                completion(false)
            }
        } else {
            loadLike(postID: postID, completion: completion)
        }
    }
    
    private func loadLike(postID: String, completion: @escaping (Bool) -> Void) {
        let userID = Auth.auth().currentUser!.uid
        let likeRef = Database.database().reference().child("PostLikes").child(postID).child(userID)
        likeRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                self.LikedPostsCache.setObject(1, forKey: postID as NSString)
                completion(true)
            }else{
                self.LikedPostsCache.setObject(0, forKey: postID as NSString)
                completion(false)
            }
        }
    }
}
