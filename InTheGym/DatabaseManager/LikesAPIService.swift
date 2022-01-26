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
    
    let LikedPostsCache = Cache<String, Bool>()
    
    func check(postID: String, completion: @escaping (Bool) -> Void) {
        
        if let liked = LikedPostsCache[postID] {
            completion(liked)
        } else {
            loadLike(postID: postID, completion: completion)
        }
    }
    
    private func loadLike(postID: String, completion: @escaping (Bool) -> Void) {
        let userID = Auth.auth().currentUser!.uid
        let likeRef = Database.database().reference().child("PostLikes").child(postID).child(userID)
        likeRef.observeSingleEvent(of: .value) { (snapshot) in
            self.LikedPostsCache[postID] = snapshot.exists()
            completion(snapshot.exists())
            
//            if snapshot.exists(){
//                self.LikedPostsCache[postID] = true
//                completion(true)
//            }else{
//                self.LikedPostsCache[postID] = false
//                completion(false)
//            }
        }
    }
}
