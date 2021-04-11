//
//  LoadFollowers.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoadFollowers: NSObject {

    
    static func returnFollowers(for user:String, completion:@escaping([String])->()){
        var followers = [String]()
        var initialLoad = true
        let followerRef = Database.database().reference().child("Followers").child(user)
        followerRef.observe(.value) { (DataSnapshot) in
            
            for child in DataSnapshot.children{
                followers.append((child as AnyObject).key)
            }
            
            if initialLoad == false{
                completion(followers)
            }
        }
        followerRef.observeSingleEvent(of: .value) { (_) in
            completion(followers)
            initialLoad = false
        }
    }
    
    static func returnCoaches(for user:String, completion:@escaping([String])->()){
        var coaches = [String]()
        var initialLoad = true
        let coachesRef = Database.database().reference().child("PlayerCoaches").child(user)
        coachesRef.observe(.value) { (DataSnapshot) in
            
            for child in DataSnapshot.children{
                coaches.append((child as AnyObject).key)
            }
            
            if initialLoad == false{
                completion(coaches)
            }
        }
        coachesRef.observeSingleEvent(of: .value) { (_) in
            completion(coaches)
            initialLoad = false
        }
    }
    
    static func returnPlayers(for user:String, completion:@escaping([Users])->()){
        var players = [Users]()
        let myGroup = DispatchGroup()
        let playerRef = Database.database().reference().child("CoachPlayers").child(user)
        playerRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children{
                myGroup.enter()
                UserIDToUser.transform(userID: (child as AnyObject).key) { (player) in
                    players.append(player)
                    myGroup.leave()
                }
                
            }
            myGroup.notify(queue: .main){
                completion(players)
            }
            
        }
        
    }
}
