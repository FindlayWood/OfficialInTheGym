//
//  GroupModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct groupModel {
    var groupID:String!
    var groupTitle:String!
    var groupDescription:String!
    var groupMembers:[Users]?
    var groupLeader:String!
    
    init?(snapshot:DataSnapshot){
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return
        }
        self.groupID = snapshot.key
        self.groupTitle = snap["title"] as? String
        self.groupDescription = snap["description"] as? String
        self.groupLeader = snap["leader"] as? String
    }
}
