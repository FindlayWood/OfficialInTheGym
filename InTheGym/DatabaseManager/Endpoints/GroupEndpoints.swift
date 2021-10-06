//
//  GroupEndpoints.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

enum GroupEndpoints: SingleDatabaseEndpoint {
    case postToGroup(groupID: String)
    
    var path: String? {
        switch self {
        case .postToGroup(let groupID):
            return "GroupPosts/\(groupID)"
        }
    }
}

extension GroupEndpoints {
    
}
