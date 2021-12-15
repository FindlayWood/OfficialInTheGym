//
//  GroupModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct groupModel: Codable, Hashable, Assignable {
    var uid: String
    var username: String
    var description: String!
    var groupMembers: [Users]?
    var leader: String!
    
    static func == (lhs: groupModel, rhs: groupModel) -> Bool {
        lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
    
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

extension groupModel: FirebaseResource {
    static var path: String {
        return "GroupPosts"
    }
    var internalPath: String {
        return "GroupPosts/\(uid)"
    }
}
