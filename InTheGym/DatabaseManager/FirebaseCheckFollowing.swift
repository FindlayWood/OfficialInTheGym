//
//  FirebaseCheckFollowing.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseCheckFollowingProtocol {
    
}

class FirebaseCheckFollowing {
    
    static let shared = FirebaseCheckFollowing()
    
    private var ref: DatabaseReference
    
    private init() {
        ref = Database.database().reference().child("Following")
    }
    
    func check(_ checkingID: String, completion: @escaping (Bool) -> Void) {
        let userID = FirebaseAuthManager.currentlyLoggedInUser.uid
        ref.child(userID).child(checkingID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
