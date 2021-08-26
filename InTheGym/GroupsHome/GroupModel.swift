//
//  GroupModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct groupModel: Codable, Assignable {
    var uid: String
    var username: String
    var description: String!
    var groupMembers: [Users]?
    var leader: String!
    
//    init?(snapshot:DataSnapshot){
//        guard let snap = snapshot.value as? [String:AnyObject] else {
//            return
//        }
//        self.uid = snap["uid"] as! String
//        self.username = snap["username"] as! String
//        self.groupDescription = snap["description"] as? String
//        self.groupLeader = snap["leader"] as? String
//    }
}
