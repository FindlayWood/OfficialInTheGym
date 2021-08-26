//
//  UserIDToUser.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CodableFirebase

class UserIDToUser:NSObject{
    
    
    static func transform(userID:String, completion: @escaping(Users)->()) {
//        let user = Users()
//        user.uid = userID
        let userRef = Database.database().reference().child("users").child(userID)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snap = snapshot.value as? [String: AnyObject] else {return}
            do {
                let user = try FirebaseDecoder().decode(Users.self, from: snap)
                completion(user)
            } catch let error {
                print(error.localizedDescription)
            }
            
//            if let snap = snapshot.value as? [String:AnyObject]{
//                user.firstName = snap["firstName"] as? String
//                user.lastName = snap["lastName"] as? String
//                user.username = snap["username"] as? String
//                user.email = snap["email"] as? String
//                user.admin = snap["admin"] as? Bool
//                user.numberOfCompletes = snap["numberOfCompletes"] as? Int
//                user.profileBio = snap["profileBio"] as? String
//                user.profilePhotoURL = snap["profilePhotoURL"] as? String
//                completion(user)
//            }
        }
        
    }
    
    static func groupIdToGroupName(groupID:String, completion: @escaping (groupModel) -> ()) {
        let groupRef = Database.database().reference().child("Groups").child(groupID)
        groupRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snap = snapshot.value as? [String:AnyObject] else {return}
            do {
                let group = try FirebaseDecoder().decode(groupModel.self, from: snap)
                completion(group)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
}
